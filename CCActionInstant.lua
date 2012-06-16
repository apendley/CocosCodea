--CCActionInstant
CCActionInstant = CCClass(CCFiniteTimeAction)

function CCActionInstant:isDone() return true end
function CCActionInstant:step(dt) self:update(1)end

---------------------------------
-- base class for caller actions
---------------------------------
CCCallBase = CCClass(CCActionInstant)

function CCCallBase:init(...)
    CCActionInstant.init(self)
    if #arg > 0 then self.params = arg end
end

function CCCallBase:execute(...) 
	ccAssert(false, "implement me!") 
end

function CCCallBase:update(t)
    local params = self.params
    self:execute(params and unpack(params) or nil)
end

-------------------------
-- call a function
-- CCFunc(f, ...) -> f(...)
-------------------------
CCFunc = CCClass(CCCallBase)

function CCFunc:init(f, ...)
    CCCallBase.init(self, ...)
    self.func = f          
end
    
function CCFunc:copy()
    local fn = self.func
    local params = self.params    
    return self.class(fn, params and unpack(params) or nil)
end

function CCFunc:execute(...) self.func(...) end
    
function CCFunc:makeCaller(fn)
    local klass = CCClass(self)
    
    function klass.init(inst, ...) self.init(inst, fn, ...) end
    
    function klass.copy(inst)
        local params = inst.params
        return klass(params and unpack(params) or nil)
    end    
        
    return klass    
end

---------------------------------------------------------------------------
-- call a function, passing the action target as the first param
-- CCFuncT(f, ...) -> f(actionTarget, ...)
---------------------------------------------------------------------------
CCFuncT = CCClass(CCFunc)
function CCFuncT:execute(...) self.func(self.target, ...) end

---------------------------------------------------------------------------
-- call a method on obj
-- CCMethod(obj, sel, ...) -> obj:sel(...)
---------------------------------------------------------------------------
CCMethod = CCClass(CCCallBase)

function CCMethod:init(obj, selector, ...)
    CCCallBase.init(self, ...)
    self.obj_ = obj
    self.selector_ = selector
end
    
function CCMethod:copy()
    local obj = self.obj_
    local sel = self.selector_
    local params = self.params
    return self.class(obj, sel, params and unpack(params) or nil)
end

function CCMethod:execute(...)    
    local obj = self.obj_
    obj[self.selector_](obj, ...)
end

---------------------------------------------------------------------------
-- call a method on obj passing the action target as the first parameter
-- CCMethodT(obj, sel, ...) -> obj:sel(actionTarget, ...)
---------------------------------------------------------------------------
CCMethodT = CCClass(CCCallMethod)

function CCMethodT:execute(...)
    local obj = self.obj_ 
    obj[self.selector_](obj, self.target, ...)
end

---------------------------------------------------------------------------
-- call a method on the action target
-- CCCallT(sel, ...) -> actionTarget:sel(...)
---------------------------------------------------------------------------
CCCallT = CCClass(CCCallBase)

function CCCallT:init(selector, ...)
    CCCallBase.init(self, ...)
    self.selector_ = selector
end

function CCCallT:copy()
    local sel = self.selector_
    local params = self.params
    return self.class(sel, params and unpack(params) or nil)
end

function CCCallT:execute(...)
    local target = self.target
    target[self.selector_](target, ...)
end

---------------------------------------
-- other instant actions
---------------------------------------
CCShow = CCFuncT:makeCaller(function(t) t:setVisible(true) end)
CCHide = CCFuncT:makeCaller(function(t) t:setVisible(false) end)
CCShow:impReverse(CCHide)

CCToggleVisibility = CCFuncT:makeCaller(function(t) t:setVisible(not t:visible()) end)

CCPlace = CCFuncT:makeCaller(function(t, x, y) t:setPosition(x, y) end)

local function ccprint_(s) ccPrint("CCPrint: "..tostring(s)) end
CCPrint = CCFunc:makeCaller(ccprint_)

local function ccprintt_(t, s) 
    ccPrint("CCPrint["..tostring(t).."]: "..tostring(s)) 
end

CCPrintT = CCFuncT:makeCaller(ccprintt_)
    

-- todo: flipX, flipY

    