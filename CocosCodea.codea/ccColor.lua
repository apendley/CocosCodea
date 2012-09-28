--ccColor
ccc3 = {__methods = {}}
ccc3.__methods.__index = ccc3.__methods

setmetatable(ccc3, 
{
    __index = ccc3.__methods,
    __newindex = ccc3.__methods,
    __call = function(self, ...) return self:new(...) end,
})

function ccc3VA(...)
    if #arg == 0 then
        return 255, 255, 255
    elseif #arg == 1 then
        if type(arg[1]) == "number" then
            local g = arg[1]
            return g, g, g
        else
            local c = arg[1]
            return c.r, c.g, c.b
        end
    elseif #arg == 2 then
        local g = arg[1]
        return g, g, g, 255
    elseif #arg == 3 then
        return unpack(arg)
    elseif #arg == 4 then
        return arg[1], arg[2], arg[3]
    else
        ccAssert(false, "ccc3VA -> invalid parameters")
    end    
end


function ccc3:new(...)
    local t = setmetatable({}, ccc3.__methods)
    t:init(...)
    return t
end

function ccc3:init(...)
    self.r, self.g, self.b = ccc3VA(...)
end

ccc3.set = ccc3.init

function ccc3:unpack()
    return self.r, self.g, self.b
end

function ccc3:copy()
    return ccc3(self.r, self.g, self.b)
end

function ccc3:__tostring()
    return "("..self.r..", "..self.g..", "..self.b..")"
end
function ccc4VA(...)
    if #arg == 0 then
        return 255, 255, 255, 255
    elseif #arg == 1 then
        if type(arg[1]) == "number" then
            local g = arg[1]
            return g, g, g, 255
        else
            local r, g, b, a = arg[1]:unpack()
            return r, g, b, a or 255
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

-- creates a color object, but processes the var args the way fill(), etc. do
ccc4 = function(...) return color(ccc4VA(...)) end