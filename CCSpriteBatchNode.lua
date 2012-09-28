--CCSpriteBatchNode
CCSpriteBatchNode = CCClass(CCNode)

CCSpriteBatchNode:synth{"smooth"}

function CCSpriteBatchNode:init(texture)
    CCNode.init(self)
    
    self.smooth_ = true
    self.textureAtlas_ = CCTextureAtlas(texture)
    self.descendants_ = {}
end

function CCSpriteBatchNode:addChild(child, z, tag)
    ccAssert(child)
    ccAssert(child:instanceOf(CCSprite))
    ccAssert(child.texture_ == self.textureAtlas_:texture())
    
    CCNode.addChild(self, child, z, tag)
    
    local index = self:atlasIndexForChild(child, z)
    self:insertChildInAtlas(child, index)
end

function CCSpriteBatchNode:reorderChild(child, z)
    ccAssert(child)
    ccAssert(ccArrayContains(self.children_, child))
    
    if z == child.zOrder then return end
    
    -- todo: instead of removing/adding, it is more efficient to reorder manually
    self:removeChild(child, false)
    self:addChild(child, z)
end

function CCSpriteBatchNode:removeChild(child, cleanup)
    if child == nil then return end
    
    ccAssert(ccArrayContains(self.children_, child))
    
    self:removeSpriteFromAtlas(child)
    CCNode.removeChild(self, child, cleanup)
end

function CCSpriteBatchNode:removeChildAtIndex(index, cleanup)
    local child = self.children_[index]
    CCNode.removeChild(self, child, cleanup)
end

function CCSpriteBatchNode:removeAllChildren(cleanup)
    ccArrayForEach(self.children_, "setBatchNode", nil)
    CCNode.removeAllChildren(self, cleanup)
    
    ccArrayClear(self.descendants_)
    self.textureAtlas_:removeAllQuads()
end

function CCSpriteBatchNode:insertChildInAtlas(child, index)
    child:setBatchNode(self)
    child.atlasIndex_ = index
    child.batchTransformDirty_ = true
    
    local descendants = self.descendants_
    
    -- we don't actually add the quad yet, because it won't be drawn until
    -- the sprite renders anyway
    --self.textureAtlas_:addQuad(self:quad())
    self.textureAtlas_:addQuad()
    ccArrayInsert(descendants, index, child)
    
    -- update indices
    for i = index+1, #descendants do
        local c = descendants[i]
        c.atlasIndex_ = c.atlasIndex_ + 1
        c.batchDirty_ = true
        c.batchTexRectDirty_ = true
        c.batchColorDirty_ = true
    end
    
    -- add children recursively
    for i,v in ipairs(child.children_) do
        local idx = self:atlasIndexForChild(v, v.zOrder)
        self:insertChildInAtlas(v, idx)
    end
end

function CCSpriteBatchNode:removeSpriteFromAtlas(s)
    -- this is a misnomer; we can't actually remove quads from Codea's mesh
    -- object, so instead we make the last one stop rendering.
    -- when we update the indicies of descendants, we'll mark them as completely
    -- dirty as well so they completely redraw next render update
    self.textureAtlas_:removeQuad()
    
    s:setBatchNode(nil)
    

    local descendants = self.descendants_
    local index = ccArrayIndexOf(descendants, s)
    if index then
        ccArrayRemove(descendants, index)
        
        for i = index, #descendants do
            local d = descendants[i]
            d.atlasIndex_ = d.atlasIndex_ - 1
            d.batchDirty_ = true
            d.batchTexRectDirty_ = true
            d.batchColorDirty_ = true 
        end
    end
    
    for i,v in ipairs(s.children_) do
        self:removeSpriteFromAtlas(v)
    end
end

function CCSpriteBatchNode:rebuildIndexInOrder(parent, index)
end

function CCSpriteBatchNode:atlasIndexForChild(child, z)
    local sisters = child.parent_.children_
    local childIndex = ccArrayIndexOf(sisters, child)
    local ignoreParent = (child.parent_ == self)
    local previous    
    
    if childIndex > 1 then
        previous = sisters[childIndex - 1]
    end
    
    if ignoreParent then
        if childIndex == 1 then 
            return 1 
        else
            return self:highestAtlasIndexInChild(previous) + 1
        end
    end
    
    if childIndex == 1 then
        return (z<0) and child.parent_.atlasIndex_ or child.parent_.atlasIndex_ + 1
    else
        if (previous.zOrder_ < 0 and z < 0) or (previous.zOrder_ >= 0 and z >= 0) then
            return self:highestAtlasIndexInChild(previous) + 1
        end
        
        return child.parent_.atlasIndex_ + 1
    end
    
    ccAssert(false) -- should never get here; error calculating z on Batch Node
    return 0
end

function CCSpriteBatchNode:lowestAtlasIndexInChild(child)
    local children = child.children_
    
    -- if array is empty
    if not next(children) then
        return sprite.atlasIndex_
    else
        return self:lowestAtlasIndexInChild(children[0])
    end
end

function CCSpriteBatchNode:highestAtlasIndexInChild(child)
    local children = child.children_
    
    -- if array is empty    
    if not next(children) then
        return child.atlasIndex_
    else
        return self:highestAtlasIndexInChild(children[#children])
    end
end

function CCSpriteBatchNode:visit()
    if not self.visible_ then return end

    pushStyle()
    pushMatrix()
    
    self:transform()
    self:draw()
    
    popMatrix()    
    popStyle()
end

function CCSpriteBatchNode:draw()
    CCNode.draw(self)
    
    local atlas = self.textureAtlas_
    if atlas.numQuads_ == 0 then return end
     
    ccArrayForEach(self.children_, "updateTransform")
    
    if self.smooth_ then
        smooth()
    else
        noSmooth()
    end

    atlas:drawQuads()
end
