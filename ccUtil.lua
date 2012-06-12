--ccUtil

------------------------
-- color utilities
------------------------
function ccColorUnpack(c) return c.r, c.g, c.b end
function ccColorRawUnpack(c) return c.r, c.g, c.b, c.a end
function ccColorCopy(c) local r,g,b = ccColorUnpack(c) return color(r, g, b, 255) end
function ccColorCopyRaw(c) return color(ccColorRawUnpack(c)) end

function ccColorRawVA(...)
    if #arg == 0 then
        return 255, 255, 255, 255
    elseif #arg == 1 then
		if type(arg[1]) == "number" then
			local g = arg[1]
			return g, g, g, 255
		else
			return ccColorRawUnpack(arg[1])
		end
	elseif #arg == 2 then
		local g = arg[1]
		return g, g, g, arg[2]
    elseif #arg == 3 then
		return arg[1], arg[2], arg[3], 255
	elseif #arg == 4 then
		return unpack(arg)
    else
        assert(false, "ccColorVA -> invalid parameters")
    end    
end

function ccColorVA(...)
    if #arg == 0 then
        return 255, 255, 255, 255
    elseif #arg == 1 then
		if type(arg[1]) == "number" then
			local g = arg[1]
			return g, g, g, 255
		else
			local r, g, b = ccColorUnpack(arg[1])
			return r, g, b, 255
		end
    elseif #arg >= 3 then
		return arg[1], arg[2], arg[3], 255
    else
        assert(false, "ccColorVA -> invalid parameters")
    end    
end

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
        assert(false, "ccVec2VA -> invalid parameters")
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
