--ccSynth

local function genSetter(propName)
    return "set" .. string.upper(string.sub(propName, 1, 1)) .. string.sub(propName, 2)
end

local function ccSynthesize(klass, t, genGetFn, genSetFn)
    local propName = t[1]
    local ivarName = t["ivar"] or propName .. "_"
    
    ccAssert(klass and propName)
    
    local mode = t["mode"] or "rw"    
    local read = string.find(mode, "r") ~= nil
    local write = string.find(mode, "w") ~= nil    

    if read then
        local getter = t["get"] or propName
        klass[getter] = genGetFn(ivarName)
    end
    
    if write then
        local setter = t["set"] or genSetter(propName)
        klass[setter] = genSetFn(ivarName)
    end    
end

function ccSynth(klass, t)
    local function genGet(ivarName)
        return function(inst) ccAssert(inst) return inst[ivarName] end
    end

    local function genSet(ivarName)
        return function(inst, value) inst[ivarName] = value end
    end    
    
    ccSynthesize(klass, t, genGet, genSet)
end

function ccSynthColor4(klass, t)
    local function genGet(ivarName)
        return function(inst)
            return ccc4Copy(inst[ivarName])
        end
    end

    local function genSet(ivarName)
        return function(inst, ...)
            inst[ivarName] = ccc4(ccc4VA(...))
        end
    end        
    
   ccSynthesize(klass, t, genGet, genSet)
end

function ccSynthColor(klass, t)
    local function genGet(ivarName)
        return function(inst)
            return ccc3Copy(inst[ivarName])
        end
    end

    -- preserves the original's alpha value
    local function genSet(ivarName)
        return function(inst, ...)
            local c = inst[ivarName]            
            if c then
                c.r, c.g, c.b = ccc3VA(...)                
            else
                inst[ivarName] = ccc3(ccc3VA(...))
            end
        end
    end        
    
   ccSynthesize(klass, t, genGet, genSet)
end


function ccSynthVec2(klass, t)
    local function genGet(ivarName)
        return function(inst)
            local v = inst[ivarName]
            return ccVec2(v.x, v.y)
        end
    end

    local function genSet(ivarName)
        return function(inst, ...)
            local x, y = ccVec2VA(...)
            local v = inst[ivarName]
            v.x, v.y = x, y
        end
    end    
     
    ccSynthesize(klass, t, genGet, genSet)
end
