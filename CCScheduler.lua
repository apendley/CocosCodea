--CCScheduler
CCScheduler = CCClass()

-- * todo:
-- * implement prioritized updates

kCCRepeatForever = -1

-- internal class used by CCScheduler
local CCTimer = CCClass()

function CCTimer:init(target, sel, interval, times, delay)
    self.target = target
    self.selector = sel
    self.interval = interval or 0
    self.elapsed = -1
    self.times = times or kCCRepeatForever
    self.delay = delay or 0
    self.nTimesExecuted = 0
    self.useDelay = (delay > 0)
    self.runForever = (times == kCCRepeatForever)
end

function CCTimer:update(scheduler, dt)
    local runForever = self.runForever
    local useDelay = self.useDelay
    
    if self.elapsed == -1 then
        self.elapsed = 0
        self.nTimesExecuted = 0
    else
        if runForever and not useDelay then
            self.elapsed = self.elapsed + dt
            if self.elapsed >= self.interval then
                self.target[self.selector](self.target, self.elapsed)
                self.elapsed = 0
            end
        else
            self.elapsed = self.elapsed + dt
            if useDelay then
                if self.elapsed >= self.delay then
                    self.target[self.selector](self.target, self.elapsed)
                    self.elapsed = self.elapsed - self.delay
                    self.nTimesExecuted = self.nTimesExecuted + 1
                    self.useDelay = false
                end
            else
                if self.elapsed >= self.interval then
                    self.target[self.selector](self.target, self.elapsed)
                    self.elapsed = 0
                    self.nTimesExecuted = self.nTimesExecuted + 1
                end
            end
            
            if self.nTimesExecuted > self.times then
                scheduler:unscheduleSelector(self.selector, self.target)
            end
        end
    end
end

function CCTimer:invalidate()
    self.target = nil
    self.selector = nil
end

local function newSelectorEntry(target, paused)
    local entry = {}
    entry.timers = {}
    entry.target = target
    entry.paused = paused    
    entry.timerIndex = 0
    entry.currentTimer = nil
    entry.timerSalvaged = nil
    return entry
end

local function invalidateEntry(entry)
    ccArrayForEach(entry.timers, "invalidate")
    ccArrayClear(entry.timers)
    entry.target = nil
    entry.currentTimer = nil
    entry.timerSalvaged = nil
end

function CCScheduler:init()
    self.timeScale_ = 1
    
    -- selectors with interval
    self.currentEntry = nil
    self.entrySalvaged = nil
    self.selectorEntries = {}
    self.updateHashLocked = false
end

function CCScheduler:removeSelectorEntry(entry)
    local target = entry.target
    invalidateEntry(entry)    
    self.selectorEntries[target] = nil
end

function CCScheduler:scheduleSelector(sel, target, interval, paused, times, delay)
    times = times or kCCRepeatForever
    delay = delay or 0
    
    --[[
    local msg = "Sel: " .. sel .. " for target: " .. tostring(target) .. "  int:" .. interval
    msg = msg .. "   times:" .. times .. "   delay:" .. delay
    ccPrint(msg)
    --]]
    
    ccAssert(sel and target)
    
    local entry = self.selectorEntries[target]
    
    if not entry then
        entry = newSelectorEntry(target, paused)
        self.selectorEntries[target] = entry
        entry.paused = paused
    else 
        -- can't schedule a selector with pause value different than target
        ccAssert(entry.paused == paused)
    end
        
    for i = 1, #entry.timers do
        local timer = entry.timers[i]
        if sel == timer.selector then
            timer.interval = interval
            return
        end      
    end

    ccArrayInsert(entry.timers, CCTimer(target, sel, interval, times, delay))
end

function CCScheduler:unscheduleSelector(sel, target)
    if not target and not sel then return end
    
    local entry = self.selectorEntries[target]
    
    if entry then
        for i = 1, #entry.timers do
            local timer = entry.timers[i]
            if sel == timer.selector then
                if timer == entry.currentTimer and not entry.timerSalvaged then
                    entry.timerSalvaged = timer
                end
                
                timer:invalidate()
                ccArrayRemove(entry.timers, i)
                
                if entry.timerIndex >= i then
                    entry.timerIndex = entry.timerIndex - 1
                end
                
                if #entry.timers == 0 then
                    if self.currentEntry == entry then
                        self.entrySalvaged = entry
                    else
                        self:removeSelectorEntry(entry)
                    end
                end
                
                return
            end
        end
    end
end


function CCScheduler:unscheduleAllSelectors()
    for k,entry in pairs(self.selectorEntries) do
        self:unscheduleAllSelectorsForTarget(entry.target)
    end
end

function CCScheduler:unscheduleAllSelectorsForTarget(target)
    if not target then return end
    
    local entry = self.selectorEntries[target]
    
    if entry then
        if ccArrayContains(entry.timers, entry.currentTimer) and not entry.timerSalvaged then
            entry.timerSalvaged = entry.currentTimer
        end
        
        --entry.timers = {}
        ccArrayClear(entry.timers)
        
        if self.currentEntry == entry then
            self.entrySalvaged = entry
        else
            self:removeSelectorEntry(entry)
        end
    end
end

function CCScheduler:resumeTarget(target)
    ccAssert(target)
    local entry = self.selectorEntries[target]
    if entry then entry.paused = false end
end

function CCScheduler:pauseTarget(target)
    ccAssert(target)
    local entry = self.selectorEntries[target]
    if entry then entry.paused = true end
end

function CCScheduler:isTargetPaused(target)
    ccAssert(target)
    local entry = self.selectorEntries[target]
    if entry then return entry.paused end
    return false    
end


function CCScheduler:pauseAllTargets()
    local pausedList = {}
    for k,entry in pairs(self.selectorEntries) do
        entry.paused = true
        ccArrayInsert(pausedList, entry.target)
    end
    return pausedList
end

function CCScheduler:resumeTargets(pausedList)
    for i,v in ipairs(pausedList) do
        self:resumeTarget(v)
    end
end

function CCScheduler:update(dt)
    self.updateLocked = true
    
    local timeScale = self.timeScale or 1
    if timeScale ~= 1 then dt = dt * timeScale end

    for k, ce in pairs(self.selectorEntries) do
        self.currentEntry = entry
        self.entrySalvaged = nil
        
        if not ce.paused then            
            ce.timerIndex = 1
            while ce.timerIndex <= #ce.timers do
                ce.currentTimer = ce.timers[ce.timerIndex]
                ce.timerSalvaged = nil
                
                ce.currentTimer:update(self, dt)
                
                if ce.timerSalvaged then ce.timerSalvaged = nil end                
                ce.timerIndex = ce.timerIndex + 1 
            end

        end
        
        if self.entrySalvaged and #self.currentEntry.timers == 0 then
            self:removeSelectorEntry(self.currentEntry)
        end
    end
    
    self.updateLocked = false
    self.currentEntry = nil
end
