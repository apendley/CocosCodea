--ccUtil

------------------------
-- color utilities
------------------------
function ccc4VA(...)
    if #arg == 0 then
        return 255, 255, 255, 255
    elseif #arg == 1 then
        if type(arg[1]) == "number" then
            local g = arg[1]
            return g, g, g, 255
        else
            return ccColorUnpack(arg[1])
        end
    elseif #arg == 2 then
        local g = arg[1]
        return g, g, g, arg[2]
    elseif #arg == 3 then
        return arg[1], arg[2], arg[3], 255
    elseif #arg == 4 then
        return unpack(arg)
    else
        ccAssert(false, "ccc4VA -> invalid parameters")
    end    
end

function ccc3VA(...)
    if #arg == 0 then
        return 255, 255, 255, 255
    elseif #arg == 1 then
        if type(arg[1]) == "number" then
            local g = arg[1]
            return g, g, g, 255
        else
            local r, g, b = ccColor3Unpack(arg[1])
            return r, g, b, 255
        end
    elseif #arg >= 3 then
        return arg[1], arg[2], arg[3], 255
    else
        ccAssert(false, "ccc3VA -> invalid parameters")
    end    
end

function ccColor3(...) return ccColor(ccc3VA(...)) end

function ccColor3Unpack(c) return c.r, c.g, c.b end
function ccColorUnpack(c) return c.r, c.g, c.b, c.a end
function ccColor3Copy(c) local r,g,b = ccColor3Unpack(c) return ccColor(r, g, b, 255) end
function ccColorCopy(c) return ccColor(ccColorUnpack(c)) end

------------------------
-- vec2 utilities
------------------------
function ccVec2VA(...)
    if #arg == 0 then
        return 0, 0
    elseif #arg == 1 then
        local v = arg[1]
        return v.x, v.y
    elseif #arg == 2 then
        return arg[1], arg[2]
    else
        ccAssert(false, "ccVec2VA -> invalid parameters")
    end
end

------------------------
-- other utilities
------------------------
function ccDelegate(obj, funcName, ...)
    return function(...) obj[funcName](obj, ...) end
end

-- probably doesn't belong here, but there's not a better place for it at the moment
ccFLT_EPSILON = 0.00000011920929
