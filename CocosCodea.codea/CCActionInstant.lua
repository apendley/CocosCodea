--CCActionInstant
CCActionInstant = CCClass(CCFiniteTimeAction)

function CCActionInstant:isDone() return true end
function CCActionInstant:step(dt) self:update(1) end

----------------------------------------------------------------------
-- call a function.
-- if a function is specified as the 1st arg, it is called.
-- otherwise, it is assumed it is an object, and that the
-- 2nd arg is the name of a member function to call on that object.
----------------------------------------------------------------------
CCCall = CCClass(CCActionInstant)

function CCCall:init(call, ...)
    CCActionInstant.init(self)
    
    if type(call) == "function" then
        self.call_ = call
    else
        self.call_ = ccDelegate(call, arg[1])
        table.remove(arg, 1)
    end
        
    if #arg > 0 then self.params = arg end
end
    
function CCCall:copy()
    local call = self.call_
    local params = self.params    
    return self.class(call, params and unpack(params) or nil)
end

function CCCall:execute(...)
    self.call_(...)
end

function CCCall:update(t)
    local params = self.params
    self:execute(params and unpack(params) or nil)
end

function CCCall:makeCaller(call)
    local klass = CCClass(self)
    
    function klass.init(inst, ...) self.init(inst, call, ...) end
    
    function klass.copy(inst)
        local params = inst.params
        return klass(params and unpack(params) or nil)
    end    
        
    return klass    
end

---------------------------------------------------------------------------
-- call a function, passing the action target as the first param,
-- followed by any arguments.
--
-- args are the same as CCCall, except that if only a method name
-- is supplied, the action calls the member function with that name
-- on the action target, passing along any arguments.
---------------------------------------------------------------------------
CCCallT = CCClass(CCCall)

local function executeFn(self, ...)
    self.call_(self.target, ...)
end

local function executeSel(self, ...)
    local target = self.target
    target[self.call_](target, ...)
end

function CCCallT:init(call, ...)
    if type(call) == "string" then
        CCActionInstant.init(self)
        self.call_ = call
        self.execute_ = executeSel
        if #arg > 0 then self.params = arg end
    else
        CCCall.init(self, call, ...)
        self.execute_ = executeFn
    end
end

function CCCallT:execute(...)
    self:execute_(...)
end

---------------------------------------
-- other instant actions
---------------------------------------
CCShow = CCCallT:makeCaller(function(t) t:setVisible(true) end)
CCHide = CCCallT:makeCaller(function(t) t:setVisible(false) end)
CCAction.impReverse(CCShow, CCHide)

CCToggleVisibility = CCCallT:makeCaller(function(t) t:setVisible(not t:visible()) end)

-- todo: flipX, flipY

CCPlace = CCCallT:makeCaller(function(t, x, y) t:setPosition(x, y) end)

local function ccprint_(s) ccPrint("CCPrint: "..tostring(s)) end
CCPrint = CCCallT:makeCaller(ccprint_)

local function ccprintt_(t, s) 
    ccPrint("CCPrint["..tostring(t).."]: "..tostring(s)) 
end

CCPrintT = CCCall:makeCaller(ccprintt_)
    


    