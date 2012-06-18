--ccSynth

local propIvarSuffix_ = "_"
local propGetPrefix_ = nil
local propSetPrefix_ = "set"

-- there is probably a much faster way to do this
local function genSetterName(propName)
    return  -- set the prefix (i.e. 'set')
            propSetPrefix_ .. 
            -- capitalize the first letter and append it
            string.upper(string.sub(propName, 1, 1)) .. 
            -- append the reset of the string
            string.sub(propName, 2)
end

local function genUnpack(ivarName)
    return function(inst)
        return inst[ivarName]:unpack()
    end
end

local function genRef(ivarName)
    return function(inst) 
        return inst[ivarName]
    end
end

local function genGetCopy(ivarName, creator)
    return function(inst)
        --return inst[ivarName]:copy() 
        
        local i = inst[ivarName]
        
        if i == nil and creator ~= nil then
            --print("genSetCopy: creating...")
            i = creator()
            inst[ivarName] = i
        end
        
        -- you either need to pass a creator into your synth
        -- call, or you need to create your ivar before your
        -- get method is called
        ccAssert(i)        
        
        return i:copy()
    end
end

local function genAssign(ivarName)
    return function(inst, value) inst[ivarName] = value end
end

local function genCopy(ivarName, creator)
    
    return function(inst, ...)
        -- don't forget to actually create your
        -- ivar, or you will see this comment.
        local i = inst[ivarName]
        
        -- if you specify a creator for your type, you can
        -- lazily create your properties. If you don't, you
        -- need to make sure to create them before the setter is called,
        -- or else you'll hit the assert below
        if i == nil and creator ~= nil then
            --print("genCopy creating...")
            --ccPrintTable{...}
            inst[ivarName] = creator(...)
            --print(inst[ivarName])
            return
        end
        
        -- you probably forgot to assign a value to your ivar
        -- in your class' init method, or assign a creator method
        ccAssert(i)
        
        if i.set then 
            i:set(...) 
        else 
            -- if type doesn't have a 'set' method, then we call copy on
            -- the first arg. this is to allow types like 'color' that have
            -- constructs with multiple 'call signatures' to work, while
            -- types without a set method can still just grab a copy.
            -- make sure you know whether or not the type you are synthesizing
            -- copy methods for
            inst[ivarName] = arg[1]:copy()
        end
    end
end

-- modes: read modes:[r#up], write modes:[ac]
-- r: generate "get" by value (return self[ivar])
-- #: generate copy on get (return self[ivar]:copy())
-- a: generate "set", direct assignment (self[ivar] = value)
-- c: generate "set", copy on assign (self[ivar] = value:copy())
-- u: generate "*Unpacked", only when c or # are specified
-- p: generate "*Ref" (return sef[ivar]) only when c or # are specified

function ccSynthesize(klass, t)
    local propName = t[1]
    local createFn = t[2]
    
    -- allow property name and creator args to be interchangeable
    if type(propName) == "function" then
    	propName, createFn = createFn, propName
    end
    
    -- must provide property name
	ccAssert(propName and type(propName) == "string")    
    
    local ivarName = t["ivar"] or propName .. propIvarSuffix_
    
    ccAssert(klass and propName)
    
    local mode = t["mode"] or "ra"
    local read = string.find(mode, "r")
    local readCopy = false
    local copy = string.find(mode, "c")    
    local write = copy or string.find(mode, "a")
    
    if read then
        if copy then readCopy = true end
    else
        if copy or string.find(mode, "#") then
            read = true
            readCopy = true
        end
    end
    
    if read then
        local getter = t["get"]    
        
        if not getter then
            getter = propGetPrefix_ and propGetPrefix_ .. propName or propName
        end        
        
        if readCopy then
            --print("genGetCopy: "..getter..", "..ivarName)
            klass[getter] = genGetCopy(ivarName, createFn)
            
            --[[
            if string.find(mode, "p") then
                klass[getter.."Ref"] = genRef(ivarName)
            end
            
            if string.find(mode, "u") then
                klass[getter.."Unpacked"] = genUnpack(ivarName)
            end
            --]]            
        else
            --print("genRef:    "..getter..", "..ivarName)
            klass[getter] = genRef(ivarName)
        end
    end
    
    if write then
        local setter = t["set"] or genSetterName(propName)

        if copy then
            --print("genCopy:   "..setter..", "..ivarName)
            klass[setter] = genCopy(ivarName, createFn)
        else
            --print("genAssign: "..setter..", "..ivarName)
            klass[setter] = genAssign(ivarName)
        end
    end
end