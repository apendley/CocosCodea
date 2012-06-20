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
    return ccVec2(m[1]*pt.x+m[5]*pt.y + m[13], m[2]*pt.x+m[6]*pt.y+m[14])
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
-- delegation
------------------------
function ccDelegate(target, selector)
    return function(...) 
        --print("ccDelegate: "..tostring(target).."["..tostring(selector).."]")
        target[selector](target, ...) 
    end
end
