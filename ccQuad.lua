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

function ccQuad:setVertex(vertIndex, ...)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    local v= self[vertIndex]
    v[1], v[2] = ccVec2VA(...)
end

function ccQuad:vertex(vertIndex)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    local v = self[vertIndex]
    return v[1], v[2]
end
    
function ccQuad:setColor(vertIndex, ...)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    local v = self[vertIndex]
    v[3], v[4], v[5], v[6] = ccc4VA(...)
end

function ccQuad:setUV(vertIndex, ...)
    ccAssert(vertIndex >= 1 and vertIndex <= 4)
    
    local v_ = self[vertIndex]
    v_[7], v_[8] = ccVec2VA(...)
end

function ccQuad:setTextureRect(...)
    local tl, bl, br, tr = self[1], self[2], self[3], self[4]
    local s, t, u, v = ccRect.va(...)    
    tl[7] = s
    tl[8] = v
    bl[7] = s
    bl[8] = t
    br[7] = u
    br[8] = t
    tr[7] = u
    tr[8] = v
end