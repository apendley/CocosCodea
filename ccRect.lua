--ccRect
ccRect = {__methods = {}}
ccRect.__methods.__index = ccRect.__methods

setmetatable(ccRect, 
{
    __index = ccRect.__methods,
    __newindex = ccRect.__methods,
    __call = function(self, ...) return self:new(...) end,
})

function ccRect:new(...)
    local t = setmetatable({}, ccRect.__methods)
    t:init(...)
    return t
end

function ccRect.va(...)
    if arg[2] then
        local x, y, w, h = unpack(arg)
        return x, y, w or 0, h or 0
    elseif arg[1] then
        return arg[1]:unpack()
    else
        return 0, 0, 0, 0
    end
end

function ccRect:init(...)
    self.x, self.y, self.w, self.h = ccRect.va(...)
end

function ccRect:containsPoint(...)
    local x, y = ccVec2VA(...)
    return x >= self.x and x <= self.x+self.w and y >= self.y and y <= self.y+self.h           
end  

function ccRect:__tostring()
    return "["..self.x..","..self.y..","..self.w..","..self.h.."]"
end

function ccRect:applyTransform(m)
    local x, y, w, h = self.x, self.y, self.w, self.h
    local Min, Max, xform = math.min, math.max, ccAffineTransform2
    
    local blx, bly = xform(0,0,m)
    local brx, bry = xform(w,0,m)
    local tlx, tly = xform(0,h,m)
    local trx, try = xform(w,h,m)
    
    local minX = Min(tlx, Min(trx, Min(blx, brx)))
    local maxX = Max(tlx, Max(trx, Max(blx, brx)))
    local minY = Min(tly, Min(try, Min(bly, bry)))
    local maxY = Max(tly, Max(try, Max(bly, bry)))
    
    return ccRect(minX, minY, maxX - minX, maxY - minY)
end

function ccRect:copy()
    return ccRect(self.x, self.y, self.w, self.h)
end

function ccRect:unpack()
    return self.x, self.y, self.w, self.h
end

function ccRect:set(...)
    self.x, self.y, self.w, self.h = ccRect.va(...)
end

-- todo: add other methods