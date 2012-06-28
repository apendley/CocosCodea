--ccUtil

------------------------
-- ccVec2 utilities
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
--ccFLT_MAX = 1e+37

function ccAffineTransform(pt, m)
    return ccVec2(m[1]*pt.x+m[5]*pt.y + m[13], 
                  m[2]*pt.x+m[6]*pt.y+m[14])
end

function ccAffineTransform2(x, y, m)
    return m[1]*x+m[5]*y+m[13], m[2]*x+m[6]*y+m[14]
end

------------------------
-- copying
------------------------
function ccShallowCopy(srcT, destT)
    destT = destT or {}
    for k,v in pairs(srcT) do destT[k] = v end
    return destT
end

------------------------
-- plist helpers
------------------------
-- converts a string with the format "{<x>,<y>}" to a vec2
function ccVec2FromStr(str)
    return vec2(string.match(str, "{([%d.-]+),([%d.-]+)}"))
end

-- converts a vec2 to a string with the format "{<x>,<y>}"
function ccStrFromVec2(v)
    return table.concat({"{", v.x, ",", v.y, "}"})
end

-- converts a string with the format "{{<x>,<y>},{<w>,<h>}}" to a ccRect
function ccRectFromStr(str)
    return ccRect(string.match(str, "{([%d.-]+),([%d.-]+)},{([%d.-]+),([%d.-]+)}"))
end

-- converts a rect to a string with the format "{{<x>,<y>},{<w>,<h>}}"
function ccStrFromRect(r)
    return table.concat({"{{", r.x, ",", r.y, "},{", r.w, ",", r.h,"}}"})
end
    
------------------------
-- delegation
------------------------
function ccDelegate(target, selector)
    return function(...) 
        target[selector](target, ...) 
    end
end
