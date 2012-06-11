CCAction = CCClass()

function CCAction:init()
    self.originalTarget = nil
    self.target = nil
    self.tag = -1
end

function CCAction:copy()
    return self.class()
end

function CCAction:startWithTarget(target)
    self.originalTarget = target
    self.target = target
end

function CCAction:stop()
    --print("CCAction:stop " .. tostring(self) .. " - setting target to nil")
    self.target = nil
end

function CCAction:isDone()
    return true
end

function CCAction:step(dt)
    -- override me
end

function CCAction:update(time)
    -- override me
end

-- implements reverse methods for reciprocal classes
function CCAction:ImplementReverse(class1, class2)
    function class1:reverse() return class2() end
    function class2:reverse() return class1() end    
end

----------------------
-- finite time action
----------------------
CCFiniteTimeAction = CCClass(CCAction)

function CCFiniteTimeAction:init(duration)
    CCAction.init(self)
    self.duration_ = (duration ~= nil) and duration or 0
    self.elapsed = 0
end

function CCFiniteTimeAction:copy()
    return self.class(self.duration_)
end

function CCFiniteTimeAction:reverse()
    assert(false, "action does not support reverse()")
end

function CCFiniteTimeAction:duration()
    return self.duration_
end

----------------------
-- repeat forever
----------------------
CCRepeatForever = CCClass(CCAction)

function CCRepeatForever:init(action)
    CCAction.init(self)
    self.action_ = action
end

function CCRepeatForever:copy()
    return CCRepeatForever(self.action_:copy())
end

function CCRepeatForever:reverse()
    return CCRepeatForver(self.action_:reverse())
end

function CCRepeatForever:isDone()
    return false
end

function CCRepeatForever:startWithTarget(target)
    CCAction.startWithTarget(self, target)
    self.action_:startWithTarget(target)
end

function CCRepeatForever:step(dt)
    local action = self.action_
    action:step(dt)
    if action:isDone() then
        local diff = action.elapsed - action.duration_
        action:startWithTarget(self.target)
        
        -- to prevent jerk, according to cocos2d-iphone
        action:step(0)
        action:step(diff)
    end
end

----------------------
-- speed
----------------------
CCSpeed = CCClass(CCAction)

function CCSpeed:init(action, speed)
    CCAction.init(self)
    self.action_ = action
    self.speed_ = speed
end

function CCSpeed:copy()
    return CCSpeed(self.action_:copy(), self.speed_)
end

function CCSpeed:reverse()
    return CCSpeed(self.action_:reverse(), self.speed_)
end

function CCSpeed:isDone()
    return self.action_:isDone()
end

function CCSpeed:stop()
    self.action_:stop()
    CCAction.stop(self)
end

function CCSpeed:startWithTarget(target)
    CCAction.startWithTarget(self, target)
    self.action_:startWithTarget(target)
end

function CCSpeed:step(dt)
    self.action_:step(dt * self.speed_)
end

-- TODO: Follow

--[[
----------------------
-- instant action
----------------------
CCActionInstant = CCClass(CCFiniteTimeAction)

function CCActionInstant:isDone()
    return true
end

function CCActionInstant:step(dt)
    self:update(1)
end

CCActionInstant = CCAction

--
-- todo: comment on CCCall and CCCallT replacing cocos2d-iphone's call actions
--
-------------------------
-- call a function
-------------------------
CCCall = CCClass(CCActionInstant)

function CCCall:init(f, ...)
    CCActionInstant.init(self)
    self.func = f
    self.params = arg
end
    
function CCCall:copy()
    local params = self.params    
    
    if not params then
        return self.class(self.func)
    else
        return self.class(self.func, unpack(params))
    end
end

function CCCall:execute(...)
    self.func(...)
end

function CCCall:update(t)
    local params = self.params
    
    if not params then
        self:execute()
    else
        self:execute(unpack(self.params))
    end
end

-- allow either . or : syntax
local function skipSelf(any, self)
    return type(self) == "table" and any or self
end

-- return a CCallT action subclass for action that calls a function
function CCCall:MakeCallerClass(f)
    local fn = skipSelf(f, self)
    local klass = CCClass(CCCall)
    function klass:init(...) CCCall.init(self, fn, ...) end
    function klass:copy() return klass(unpack(self.params)) end    
    return klass    
end

CCCallT = class(CCCall)

function CCCallT:execute(...)
    self.func(self.target, ...)
end

-- return a CCallT action subclass for action that calls a function
function CCCallT:MakeCallerClass(f)
    local fn = skipSelf(f, self)    
    local klass = CCClass(CCCallT)
    function klass:init(...) CCCallT.init(self, fn, ...) end
    function klass:copy() return klass(unpack(self.params)) end    
    return klass    
end

--------------------------------------------------------------------------------
-- commonly used actions implemented in terms of CCCall(T)
--------------------------------------------------------------------------------
CCShow = CCCallT:MakeCallerClass(function(t) t:setVisible(true) end)
CCHide = CCCallT:MakeCallerClass(function(t) t:setVisible(false) end)
CCAction:ImplementReverse(CCShow, CCHide)

CCToggleVisibility = CCCallT:MakeCallerClass(function(t) t:setVisible(not t:visible()) end)

CCPlace = CCCallT:MakeCallerClass(function(t, x, y) t:setPosition(x, y) end)

CCPrint = CCCall:MakeCallerClass(function(str) print(str) end)
CCPrintT = CCCallT:MakeCallerClass(function(target, str) print(tostring(target)..": "..str) end)

-- todo: flipX, flipY

--]]
    