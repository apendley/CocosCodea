CCNode = CCClass()

-- private methods
local function insertChild(node, child, z)
    local children = node.children
    local last = children[#children]
    
    if last == nil or last.zOrder <= z then
        table.insert(children, child)
    else
        for i,v in ipairs(children) do
            if last.zOrder > z then
                table.insert(children, child, i)
                break
            end
        end
    end
    
    child.zOrder = z
end

-- Node methods
function CCNode:init()
    self.position_ = vec2(0,0)
    self.anchorPoint_ = vec2(0,0)
    self.anchorPointInPoints_ = vec2(0,0)
    self.ignoreAnchorPointForPosition_ = false
    self.contentSize_ = vec2(0,0)
    self.rotation_ = 0
    self.scaleX_ = 1
    self.scaleY_ = 1
    self.zOrder_ = 0
    self.transform_ = matrix()
    self.isTransformDirty_ = true
    self.isRunning_ = false    
    self.visible_ = true
    
    self.tag = -1    
    self.children = {}
    
    local dir = CCDirector:instance()
    self.actionManager_ = dir.actionManager
    self.scheduler_ = dir.scheduler
end

function CCNode:addChild(child, z, tag)
    insertChild(self, child, z or 0)
    if tag ~= nil then child.tag = tag end
    child.parent = self
end

function CCNode:getChildByTag(tag)
    for i,v in ipairs(self.children) do
        if v.tag == tag then return v end
    end
    
    return nil
end

function CCNode:reorderChild(child, z)
    local idx = getChildIndex(self, child)
    
    if idx then        
        local c = self.children[idx]
        table.remove(self.children, idx)
        insertChild(self, child, z)
    end
end

function CCNode:detachChild(child, cleanup)
    if self.isRunning_ then
        child:onExitTransitionDidStart()
        child:onExit()
    end
    
    if cleanup then child:cleanup() end
        
    child.parent = nil
    arrayRemoveObject(self.children, child)
end

function CCNode:removeChild(child, cleanup)
    if not child then return end

    --default cleanup = true
    if cleanup == nil then cleanup = true end
    
    if arrayContainsObject(child) then
        self:detachChild(child, cleanup)
    end
end

function CCNode:removeChildByTag(tag, cleanup)
    child = self:getChildByTag(tag)
    
    if child then
        -- default cleanup = true
        if cleanup == nil then cleanup = true end
        self:removeChild(child, cleanup)
    end
end

function CCNode:removeAllChildren(cleanup)
    -- default cleanup to true
    if cleanup == nil then cleanup = true end
    
    for i, child in ipairs(self.children) do
        if self.isRunning_ then
            child:onExitTransitionDidStart()
            child:onExit()
        end
        
        if cleanup then child:cleanup() end
        child.parent = nil
    end
    
    self.children = {}
end

function CCNode:removeFromParent(cleanup)
    if self.parent then
        -- default cleanup = true
        if cleanup == nil then cleanup = true end
        self.parent:removeChild(self, cleanup)
    end
end

function CCNode:cleanup()
    print("cleanup: " .. tostring(self))
    self:stopAllActions()
    --self:unscheduleAllSelectors()
    arrayPerformSelectorOnObjects(self.children, "cleanup")
end

function CCNode:transform()
    applyMatrix( self:nodeToParentTransform() )    
end

function CCNode:visit()
    if not self.visible_ then return end
    
    pushStyle()
    pushMatrix()
    
    self:transform()
    
    local children = self.children      
    
    -- draw children with zOrder < 0
    local cidx = 1
    while cidx <= #children do
        local c = children[cidx]
        if c.zOrder_ < 0 then
            c:visit()
            cidx = cidx + 1
        else
            break
        end
    end

    self:draw()
    
    -- draw children with zOrder >= 0
    for cidx = cidx, #children do
        local c = children[cidx]
        c:visit()        
    end
    
    popMatrix()
    popStyle()
end

function CCNode:nodeToParentTransform()
    local xform = self.transform_
    
    if self.isTransformDirty_ then
        local pos, app = self.position_, self.anchorPointInPoints_
        local x, y, sx, sy = pos.x, pos.y, self.scaleX_, self.scaleY_
        local c, s, angle = 1, 0, self.rotation_
        
        if angle ~= 0 then
            local rad = -math.rad(angle)
            c, s = math.cos(rad), math.sin(rad)
        end
        
        if self.ignoreAnchorPointForPosition_ then
            x = x + app.x
            y = y + app.y
        end        
        
        if app ~= vec2(0, 0) then
            x = x + (c * -app.x * sx) + (-s * -app.y * sy)
            y = y + (s * -app.x * sx) + (c * -app.y * sy)
        end
        
        xform[1] = c * sx
        xform[2] = s * sx
        xform[5] = -s * sy
        xform[6] = c * sy
        xform[13] = x
        xform[14] = y
        
        self.isTransformDirty_ = false
    end
    
    return xform
end

--------------------
-- properties
--------------------

function CCNode:visible(_)
    assert(_ == nil)
    return self.visible_
end

function CCNode:setVisible(visible)
    self.visible_ = (visible ~= nil ) and visible or false
end

function CCNode:rotation(_)
    assert(_ == nil)    
    return self.rotation_
end

function CCNode:setRotation(angle)
    self.rotation_ = angle
    self.isTransformDirty_ = true
end

function CCNode:scaleX(_)
    assert(_ == nil)
    return self.scaleX_    
end

function CCNode:setScaleX(s)
    self.scaleX_ = s
    self.isTransformDirty_ = true    
end

function CCNode:scaleY(_)
    assert(_ == nil)
    return self.scaleY_
end

function CCNode:setScaleY(s)
    self.scaleY_ = s
    self.isTransformDirty_ = true    
end

function CCNode:scale(_)
    assert(_ == nil)
    -- this won't behave the way you expect if scaleX and scaleY arent' the same
    return self.scaleX_        
end

function CCNode:setScale(...)
    if #arg == 1 then
        local s = arg[1]
        self.scaleX_, self.scaleY_ = s, s
    else
        self.scaleX_, self.scaleY_ = arg[1], arg[2]
    end
        
    self.isTransformDirty_ = true    
end

function CCNode:position(_)
    assert(_ == nil)
    local pos = self.position_
    return vec2(pos.x, pos.y)
end

function CCNode:setPosition(...)
    local pos = self.position_
    
    if #arg == 1 then
        local p = arg[1]
        pos.x, pos.y = p.x, p.y
    else
        pos.x, pos.y = arg[1], arg[2]
    end
    
    self.isTransformDirty_ = true
end

function CCNode:ignoreAnchorPointForPosition(_)
    assert(_ == nil)
    return self.ignoreAnchorPointForPosition_
end

function CCNode:setIgnoreAnchorPointForPosition(ignore)
    if ignore ~= self.ignoreAnchorPointForPosition_ then
        self.ignoreAnchorPointForPosition_ = ignore
        self.isTransformDirty_ = true
    end    
end

function CCNode:anchorPoint(_)
    assert(_ == nil)
    local ap = self.anchorPoint_
    return vec2(ap.x, ap.y)
end

function CCNode:setAnchorPoint(...)
    local ap = self.anchorPoint_
    
    if #arg == 1 then
        local p = arg[1]
        ap.x, ap.y = p.x, p.y 
    else
        ap.x, ap.y = arg[1], arg[2]
    end
        
    local cs, app = self.contentSize_, self.anchorPointInPoints_
    app.x, app.y = cs.x * ap.x, cs.y * ap.y
    self.isTransformDirty_ = true
end

function CCNode:contentSize(_)
    assert(_ == nil)
    local cs = self.contentSize_    
    return vec2(cs.x, cs.y)
end

function CCNode:setContentSize(...)
    local cs = self.contentSize_
    
    if #arg == 1 then
        local s = arg[1]
        cs.x, cs.y = s.x, s.y
    else
        cs.x, cs.y = arg[1], arg[2]
    end
        
    local ap, app = self.anchorPoint_, self.anchorPointInPoints_
    app.x, app.y = cs.x * ap.x, cs.y * ap.y
    self.isTransformDirty_ = true        
end

---------------------
-- scene management
---------------------

function CCNode:draw()
end

function CCNode:onEnter()
    --print("onEnter: " .. tostring(self)) 
    arrayPerformSelectorOnObjects(self.children, "onEnter")
    self:resumeSchedulerAndActions()
    
    self.isRunning_ = true
end

function CCNode:onEnterTransitionDidFinish()
    --print("onEnterTransitionDidFinish: " .. tostring(self)) 
    arrayPerformSelectorOnObjects(self.children, "onEnterTransitionDidFinish")
end

function CCNode:onExitTransitionDidStart()
    --print("onExitTransitionDidStart: " .. tostring(self))     
    arrayPerformSelectorOnObjects(self.children, "onExitTransitionDidStart")
end

function CCNode:onExit()
    --print("onExit: " .. tostring(self))     
    self:pauseSchedulerAndActions()
    self.isRunning_ = false
    
    arrayPerformSelectorOnObjects(self.children, "onExit")
end

---------------------
-- actions
---------------------
function CCNode:actionManager(am)
    if am == nil then
        return self.actionManager_
    else
        if self.actionManager_ ~= am then
            self:stopAllActions()
            self.actionManager_ = am
        end
    end
end

function CCNode:runAction(action)
    return self.actionManager_:addAction(action, self, self.isRunning_ == false)
end

function CCNode:stopAllActions()
    self.actionManager_:removeAllActionsFromTarget(self)
end

function CCNode:stopAction(action)
    self.actionManager_:removeAction(action)
end

function CCNode:stopActionByTag(tag)
    self.actionManager_:removeActionByTag(tag, self)
end

function CCNode:getActionByTag(tag)
    return self.actionManager_:getActionByTag(tag, self)
end

function CCNode:numberOfRunningActions()
    return self.actionManager_:numberOfRunningActionsInTarget(self)
end



---------------------
-- scheduler
---------------------
function CCNode:scheduler()
    return self.scheduler_
end

function CCNode:schedule(selector, interval, times, delay)
    interval = interval or 0
    assert(selector and (interval >= 0))
    return self.scheduler_:scheduleSelector(selector, self, interval, not self.isRunning_, times, delay)
end

function CCNode:unschedule(selector)
    if selector == nil then return end
    self.scheduler_:unscheduleSelector(selector, self)
end

function CCNode:unscheduleAllSelectors()
    self.scheduler_:unscheduleAllSelectorsForTarget(self)
end

function CCNode:resumeSchedulerAndActions()
    self.scheduler_:resumeTarget(self)
    self.actionManager_:resumeTarget(self)
end

function CCNode:pauseSchedulerAndActions()
    self.scheduler_:pauseTarget(self)    
    self.actionManager_:pauseTarget(self)    
end

