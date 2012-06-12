--CCActionInstant
CCActionInstant = CCClass(CCFiniteTimeAction)

function CCActionInstant:isDone()
    return true
end

function CCActionInstant:step(dt)
    self:update(1)
end


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

CCCallT = CCClass(CCCall)

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

CCPrint = CCCall:MakeCallerClass(function(str) ccPrint(str) end)
CCPrintT = CCCallT:MakeCallerClass(function(target, str) ccPrint(tostring(target)..": "..str) end)

-- todo: flipX, flipY
    