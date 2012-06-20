--CCTextureAtlas
CCTextureAtlas = CCClass()

-- texture will either be a filename or an "image" object
function CCTextureAtlas:init(texture)
    -- todo: need a free list for "removed" quads
    local m = mesh()
    m.texture = texture 
    self.mesh_ = m
    
    self.numFree_ = 0
    self.numQuads_ = 0
end

function CCTextureAtlas:texture()
    return self.mesh_.texture
end

function CCTextureAtlas:setTexture(texture)
    self.mesh_.texture = texture
end

local quadMap_ = {1, 2, 3, 1, 3, 4}

function CCTextureAtlas:updateQuad(quad, index, doVerts, doColor, doTexCoords)
    doVerts = doVerts ~= nil or true
    doColor = doColor ~= nil or true
    doTexCoords = doTexCoords ~= nil or true
    
    -- for now, just copy all of the quad data
    local first = (index-1) * 6 + 1
    local mesh = self.mesh_
       
    local v
    for i = 1, 6 do
        v = quad:vertexRef(quadMap_[i])
        
        if doVerts then
            mesh:vertex(first, v[1], v[2])
        end
        
        if doColor then
            mesh:color(first, v[3], v[4], v[5], v[6])
        end
        
        if doTexCoords then
            mesh:texCoord(first, v[7], v[8])
        end
    end
end

function CCTextureAtlas:addQuad(quad)
    if self.numFree_ > 0 then
        self.numFree_ = self.numFree_ - 1
        self.numQuads_ = self.numQuads_ + 1
    else
        self.mesh_:addRect(0, 0, 0, 0, 0)
        self.numQuads_ = self.numQuads_ + 1
    end
    
    -- index of added quad
    return numQuads_            
end

function CCTextureAtlas:removeQuad()
    -- we can't actually remove quads, so what we'll do is assume
    -- the user will shift their indices, and we'll clear the back item    
    local last = self.numQuads_
    self.mesh_:setRect(last, 0, 0, 0, 0)    
    
    self.numQuads_ = self.numQuads_ - 1
    self.numFree_ = self.numFree_ + 1
end

function CCTextureAtlas:removeAllQuads(index)
    self.numFree_ = 0
    self.numQuads_ = 0
    self.mesh_:clear()
end

function CCTextureAtlas:drawQuads()
    local s = self.mesh_.size
    
    --[[
    for i = 1, s do
        --local v = self.mesh_:vertex(i)
        --local v = self.mesh_:color(i)
        local v = self.mesh_:texCoord(i)
        print(i..": "..tostring(v))
    end
    --]]
    
    
    self.mesh_:draw()
end
