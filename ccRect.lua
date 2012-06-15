--ccRect = CCClass()
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

function ccRect:init(...)
    if type(arg[1]) == "number" then
        self.x = arg[1] or 0
        self.y = arg[2] or 0
        self.w = arg[3] or 0
        self.h = arg[4] or 0        
    else
        local r = arg[1]
        self.x = r.x
        self.y = r.y
        self.w = r.w
        self.h = r.y
    end
end

function ccRect:containsPoint(...)
    local x, y
    if #arg == 1 then
        local p = arg[1]
        x,y = p.x, p.y
    else
        x, y = arg[1], arg[2]
    end
    
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

-- todo: add other methods