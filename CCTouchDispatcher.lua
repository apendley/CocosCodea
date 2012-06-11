CCTouchDispatcher = CCClass()

kCCTouchPriorityMin = -10000

local function createTargetedTouchHandler(delegate, priority, swallowsTouches)
    local t = {}
    t.claimedTouches = {}    -- a set of touch ids
    t.delegate = delegate
    t.priority = (priority ~= nil) and priority or 0
    t.swallowsTouches = (swallowsTouches ~= nil) and swallowsTouches or true
    return t
end

local function invalidateTargetedTouchHandler(t)
    t.claimedTouches = nil
    t.delegate = nil
end

-- singleton
local dispatcherInstance = nil
function CCTouchDispatcher:instance(_)
    if not dispatcherInstance then dispatcherInstance = CCTouchDispatcher() end
    return dispatcherInstance
end

function CCTouchDispatcher:init()
    self.targetedHandlers = {}
    self.handlersToAdd = {}
    self.handlersToRemove = {}
    self.locked = false
    self.toAdd = false
    self.toRemove = false
    self.toQuit = false
end

function CCTouchDispatcher:touched(touch)
    local handlers = self.targetedHandlers
    local claimed
    
    for i,handler in ipairs(handlers) do

        claimed = false
        local delegate = handler.delegate
        
        if touch.state == BEGAN then
            if delegate.ccTouched then
                claimed = delegate:ccTouched(touch)
            else
                claimed = delegate:ccTouchBegan(touch)
            end
            
            if claimed then handler.claimedTouches[touch.id] = true end
        elseif handler.claimedTouches[touch.id] then
            claimed = true
            
            if delegate.ccTouched then
                delegate:ccTouched(touch)
            else
                local sel = (touch.state == MOVING) and "ccTouchMoved" or "ccTouchEnded"
                if delegate[sel] then
                    delegate[sel](handler.delegate, touch)
                end                
            end
            
            if touch.state == ENDED then
                handler.claimedTouches[touch.id] = nil
            end
        end
        
        if claimed and handler.swallowsTouches then break end
    end
end

function CCTouchDispatcher:updatePreDraw()
    self.locked = false
    
    if self.toAdd then
        self.toAdd = false
        
        for i,handler in ipairs(self.handlersToAdd) do
            self:forceAddHandler(handler, self.targetedHandlers)
        end
        
        arrayRemoveAllObjects(self.handlersToAdd)
    end
    
    if self.toRemove then
        self.toRemove = false
        
        for i,handler in ipairs(self.handlersToRemove) do
            self:forceRemoveDelegate(delegate)
        end
        
        arrayRemoveAllObjects(self.handlersToRemove)
    end
    
    if self.toQuit then
        self.toQuit = false
        self:forceRemoveAllDelegates()
    end
end

function CCTouchDispatcher:updatePostDraw()
    self.locked = true
end

function CCTouchDispatcher:forceAddHandler(handler, array)
    local count = 1
    
    for i,h in ipairs(array) do
        if h.priority < handler.priority then count = count + 1 end
        
        -- already added touch handler
        assert(h.delegate ~= handler.delegate)
    end
    
    table.insert(array, count, handler)
end

function CCTouchDispatcher:addTargetedDelegate(delegate, priority, swallowsTouches)
    -- a delegate must implement one of these functions
    -- if both are exist, ccTouched has priority
    assert(delegate.ccTouched or delegate.ccTouchBegan)
    
    local handler = createTargetedTouchHandler(delegate, priority, swallowsTouches)
    
    if not self.locked then
        self:forceAddHandler(handler, self.targetedHandlers)
    else
        table.insert(self.handlersToAdd, handler)
        self.toAdd = true
    end
end

function CCTouchDispatcher:forceRemoveDelegate(delegate)
    for i,handler in ipairs(self.targetedHandlers) do
        if handler.delegate == delegate then
            invalidateTargetedTouchHandler(handler)
            table.remove(self.targetedHandlers, i)
            break
        end
    end
end

function CCTouchDispatcher:removeDelegate(delegate)
    if delegate == nil then return end
    
    if not self.locked then
        self:forceRemoveDelegate(delegate)
    else
        table.insert(self.handlersToRemove, handler)
        self.toRemove = true
    end
end

function CCTouchDispatcher:forceRemoveAllDelegates()
    arrayCallFunctionOnObjects(self.targetedHandlers, invalidateTargetedTouchHandler)
    arrayRemoveAllObjects(self.targetedHandlers)
end

function CCTouchDispatcher:removeAllDelegates()
    if not self.locked then
        self:forceRemoveAllDelegates()
    else
        self.toQuit = true
    end
end

function CCTouchDispatcher:findHandler(delegate)
    for i,handler in ipairs(self.targetedHandlers) do
        if handler.delegate == delegate then return handler end
    end
    
    if self.toAdd then
        for i,handler in ipairs(self.handlersToAdd) do
            if handler.delegate == delegate then return handler end
        end
    end
    
    return nil
end

function CCTouchDispatcher:rearrangeHandlers(array)
    arrayBubbleSort(array, arrayLessThan, "priority")
end

function CCTouchDispatcher:setPriority(delegate, priority)
    assert(delegate)    
    local handler = self:findHandler(delegate)    
    assert(handler)
    handler.priority = priority
    arrayBubbleSort(self.targetedHandlers, arrayLessThan, "priority")
end


