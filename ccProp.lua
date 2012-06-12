--ccProp

local function genSetter(propName)
    return "set" .. string.upper(string.sub(propName, 1, 1)) .. string.sub(propName, 2)
end

local function ccSynth(t, genGetFn, genSetFn)
    local klass = t[1]
    local propName = t[2]
    local ivarName = t[3] or propName .. "_"
    
    ccAssert(klass and propName)
    
    local mode = t["mode"] or "rw"    
    local read = string.find(mode, "r") ~= nil
    local write = string.find(mode, "w") ~= nil    

    if read then
        local getter = t["getter"] or propName
        klass[getter] = genGetFn(ivarName)
    end
    
    if write then
        local setter = t["setter"] or genSetter(propName)
        klass[setter] = genSetFn(ivarName)
    end    
end

function ccProp(t)
    local function genGet(ivarName)
        return function(inst) ccAssert(inst) return inst[ivarName] end
    end

    local function genSet(ivarName)
        return function(inst, value) inst[ivarName] = value end
    end    
    
    ccSynth(t, genGet, genSet)
end

function ccPropColor(t)
    local function genGet(ivarName)
        return function(inst)
            return ccColorCopy(inst[ivarName])
        end
    end

    local function genSet(ivarName)
        return function(inst, ...)
            inst[ivarName] = ccColor(ccColorVA(...))
        end
    end        
    
   ccSynth(t, genGet, genSet)
end

function ccPropColorRaw(t)
    local function genGet(ivarName)
        return function(inst)
            return ccColorCopyRaw(inst[ivarName])
        end
    end

    local function genSet(ivarName)
        return function(inst, ...)
            inst[ivarName] = ccColor(ccColorRawVA(...))
        end
    end
    
    ccSynth(t, genGetColorRaw, genSetColorRaw)
end

function ccPropVec2(t)
    local function genGet(ivarName)
        return function(inst)
            local v = inst[ivarName]
            return vec2(v.x, v.y)
        end
    end

    local function genSet(ivarName)
        return function(inst, ...)
            local x, y = ccVec2VA(...)
            local v = inst[ivarName]
            v.x, v.y = x, y
        end
    end    
     
    ccSynth(t, genGet, genSet)
end
