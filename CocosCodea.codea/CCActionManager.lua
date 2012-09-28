--CCActionManager
CCActionManager = CCClass()

local function newEntry(target, paused)
    local entry = {}
    entry.actions = {}    
    entry.paused = false
    entry.salvagedAction = nil
    entry.target = target
    entry.currentAction = nil 
    entry.actionIndex = 1
    return entry
end

function CCActionManager:init()
    self.targets = {}
    self.currentTargetEntry = nil
    self.salvagedTargetEntry = nil
end

function CCActionManager:addAction(action, target, paused)
    ccAssert(action)
    local entry = self.targets[target]
    
    if entry == nil then
        entry = newEntry(target, paused)
        self.targets[target] = entry
    end
    
    ccArrayInsert(entry.actions, action)
    action:startWithTarget(target)
end

function CCActionManager:removeAllActions()
    for k,entry in pairs(self.targets) do
        self:removeAllActionsFromTarget(entry.target)        
    end
end

function CCActionManager:removeAllActionsFromTarget(target)
    if target == nil then return end
    
    local entry = self.targets[target]
    
    if entry then
        local containsAction = ccArrayContains(entry.actions, entry.currentAction)
        if containsAction and (entry.salvagedAction == nil) then
            entry.salvagedAction = entry.currentAction
        end
        
        entry.actions = {}
        
        if self.currentTargetEntry == entry then
            self.salvagedTargetEntry = entry
        else
            self.targets[entry.target] = nil
        end
    end
end

function CCActionManager:removeAction(action)
    --ccPrint("ActionManager:removeAction " .. tostring(action))    
    if action == nil then return end
    
    local entry = self.targets[action.originalTarget]
    
    if entry then
        local idx = ccArrayIndexOf(entry.actions, action)
        
        if idx ~= nil then
            self:removeActionAtIndex(idx, entry)
        end
    end
end

function CCActionManager:removeActionAtIndex(index, entry)
    local action = entry.actions[index]
    
    --ccPrint("CCActionManager:removeActionAtIndex (" .. tostring(action) .. ") [" .. index .. "]  " .. tostring(entry) .. "\n") 
    
    if action == entry.currentAction and (entry.salvagedAction == nil) then
        --ccPrint("ActionManager:removeActionAtIndex salvaging action " .. tostring(entry.currentAction) .. "\n")
        entry.salvagedAction = entry.currentAction
    end
    
    ccArrayRemove(entry.actions, index)
    
    -- update actionIndex in case we are in update, looping over the actions
    -- careful, may have an off by 1 issue here...
    if entry.actionIndex >= index then
        entry.actionIndex = entry.actionIndex - 1
    end
    
    if #entry.actions == 0 then
        if self.currentTargetEntry == entry then
            self.salvagedTargetEntry = entry
        else
            self.targets[entry.target] = nil
        end
    end
end

function CCActionManager:removeActionByTag(tag, target)
    ccAssert(tag ~= -1, "ActionManager.removeActionByTag: invalid tag")
    ccAssert(target ~= nil, "ActionManager.removeActionByTag: target should not be nil")
    
    local entry = self.targets[target]
    
    if entry then
        for i, action in ipairs(entry.actions) do
            if action.tag_ == tag and action.originalTarget == target then
                self:removeActionAtIndex(i, entry)
                break
            end
        end
    end    
end

function CCActionManager:getActionByTag(tag, target)
    local entry = self.targets[target]
    
    if entry then
        -- uhh..don't know if this check is necessary...I don't remember
        -- ever setting actions array to nil
        --if entry.actions then
            for i, action in ipairs(entry.actions) do
                if action.tag_ == tag then return action end
            end
        --end        
    end
end

function CCActionManager:numberOfRunningActionsInTarget(target)
    local entry = self.targets[target]    
    return entry and #entry.actions or 0
end

function CCActionManager:pauseTarget(target)
    local entry = self.targets[target]    
    if entry then entry.paused = true end
end

function CCActionManager:resumeTarget(target)
    local entry = self.targets[target]    
    if entry then entry.paused = false end    
end

-- returns an array of targets whose actions were paused
function CCActionManager:pauseAllRunningActions()
    local targetsWithActions = {}
    
    for _, entry in pairs(self.targets) do
        if entry.paused == false then
            entry.paused = true
            ccArrayInsert(targetsWithActions, target)
        end
    end
    
    return targetsWithActions
end

-- takes an array of targets to resume
function CCActionManager:resumeTargets(targets)
    for _, target in ipairs(targets) do
        self:resumeTarget(target)
    end
end

function CCActionManager:update(dt)
    local targets = self.targets
    
    for _, entry in pairs(targets) do
        self.currentTargetEntry = entry
        self.salvagedTargetEntry = nil        
        local cte = entry
        
        if cte.paused == false then
            cte.actionIndex = 1
            while cte.actionIndex <= #cte.actions do
                -- the entry's actions array may change while inside this loop
                cte.currentAction = cte.actions[cte.actionIndex]                    
                cte.salvagedAction = nil
                
                --ccPrint("Stepping [" .. tostring(cte.currentAction) .. "]")
                cte.currentAction:step(dt)
                
                if cte.salvagedAction ~= nil then
                    -- the currentAction told the node to remove it.
                    -- to prevent the action from accidentally deallocating
                    -- itself before finishing it's step, we "retained" it.
                    -- now that the step is done, it's safe to release it
                    cte.salvagedAction = nil
                elseif cte.currentAction:isDone() then
                    --ccPrint("CCActionManager: stopping " .. tostring(cte.currentAction))
                    cte.currentAction:stop()
                    --make currentAction nil to prevent removeAction from salvaging it
                    local a = cte.currentAction
                    cte.currentAction = nil
                    self:removeAction(a)
                end
                
                cte.currentAction = nil                
                cte.actionIndex = cte.actionIndex + 1
            end
        end
        
        -- only delete currentTargetEntry if no actions were
        -- scheduled during the cycle
        if self.salvagedTargetEntry ~= nil and #cte.actions == 0 then
            targets[cte.target] = nil
        end
    end
    
    self.currentTargetEntry = nil
end