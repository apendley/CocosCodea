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
            return ccc4Unpack(arg[1])
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
            local r, g, b = ccc3Unpack(arg[1])
            return r, g, b, 255
        end
    elseif #arg == 2 then
        local g = arg[1]
        return g, g, g, 255
    elseif #arg >= 3 then
        return arg[1], arg[2], arg[3], 255
    else
        ccAssert(false, "ccc3VA -> invalid parameters")
    end    
end

function ccc3(...) return ccColor(ccc3VA(...)) end
function ccc4(...) return ccColor(ccc4VA(...)) end

function ccc3Unpack(c) return c.r, c.g, c.b end
function ccc4Unpack(c) return c.r, c.g, c.b, c.a end
function ccc3Copy(c) local r,g,b = ccc3Unpack(c) return ccc3(r, g, b, 255) end
function ccc4Copy(c) return ccc4(ccc4Unpack(c)) end

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
-- math utilities
------------------------
ccFLT_EPSILON = 0.00000011920929

-- todo: rename to ccAffineTransform
function affineTransform(pt, m)
    return vec2(m[1]*pt.x+m[5]*pt.y + m[13], m[2]*pt.x+m[6]*pt.y+m[14])
end

-- todo: rename to ccAffineTransform2
function affineTransform2(x, y, m)
    return m[1]*x+m[5]*y+m[13], m[2]*x+m[6]*y+m[14]
end

------------------------
-- copying
------------------------
function ccShallowCopy(destT, srcT)
    for k,v in pairs(srcT) do destT[k] = v end
end
    
------------------------
-- delegation
------------------------
function ccDelegate(obj, funcName)
    return function(...) obj[funcName](obj, ...) end
end
