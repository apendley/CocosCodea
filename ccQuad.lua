--ccQuad
ccQuad = {__methods = {}}
ccQuad.__methods.__index = ccQuad.__methods

setmetatable(ccQuad, 
{
    __index = ccQuad.__methods,
    __newindex = ccQuad.__methods,
    __call = function(self, ...) return self:new(...) end,
})

function ccQuad:new(...)
    local t = setmetatable({}, ccQuad.__methods)
    t:init(...)
    return t
end

local function newVertex(r, b, g, a, u, v)
    return {0, 0, r or 255, g or 255, b or 255, a or 255, u or 0, v or 0}
end

function ccQuad:init(r, g, b, a, s, t, tw, th)
    -- tl
    self[1] = newVertex(r, g, b, a, s, th)
    
    -- bl
    self[2] = newVertex(r, g, b, a, s, t)
    
    -- br
    self[3] = newVertex(r, g, b, a, tw, t)
    
    -- tr
    self[4] = newVertex(r, g, b, a, tw, th)
end

function ccQuad:vertex(vertIndex)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    return unpack(self[vertIndex])
end

function ccQuad:vertexRef(vertIndex)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    return self[vertIndex]    
end

function ccQuad:setVertex(vertIndex, x, y, r, g, b, a, u, v)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    local v = self[vertIndex]
    v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8] = x, y, r, g, b, a, u, v    
end

function ccQuad:position(vertIndex)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    local v = self[vertIndex]
    return v[1], v[2]    
end

function ccQuad:setPosition(vertIndex, ...)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    local v= self[vertIndex]
    v[1], v[2] = ccVec2VA(...)
end
    
function ccQuad:setColor(vertIndex, ...)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    local v = self[vertIndex]
    v[3], v[4], v[5], v[6] = ccc4VA(...)
end

function ccQuad:color(vertIndex)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    local v = self[vertIndex]
    return v[3], v[4], v[5], v[6]
end

function ccQuad:setUV(vertIndex, ...)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    
    local v_ = self[vertIndex]
    v_[7], v_[8] = ccVec2VA(...)
end

function ccQuad:uv(vertIndex)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    local v = self[vertIndex]    
    return v[7], v[8]
end

function ccQuad:setTextureRect(...)
    local v1, v2, v3, v4 = self[1], self[2], self[3], self[4]
    local x, y, w, h = ccRect.va(...)    
    v1[7] = x
    v1[8] = h
    v2[7] = x
    v2[8] = y
    v3[7] = w
    v3[8] = y
    v4[7] = w
    v4[8] = h
end

function ccQuad:rect()
    local tl, br = self[1], self[3]
    return tl[1], br[1], tl[2], bl[2]
end

function ccQuad:textureRect()
    local tl, br = self[1], self[3]
    -- l, r, t, b
    return tl[7], br[7], tl[8], bl[8]
end

function ccQuad:textureRectNormalized(...)
    local w, h = ccVec2VA(...)
    local iw = 1/w
    local ih = 1/h
    local tl, br = self[1], self[3]
    -- l, r, t, b
    return tl[7] * iw, br[7] * iw, tl[8] * ih, bl[8] * ih
end