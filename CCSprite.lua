--CCSprite
CCSprite = CCClass(CCNode):include(CCRGBAMixin)

CCSprite:synth{"flipX", mode="r"}
CCSprite:synth{"flipY", mode="r"}

function CCSprite:init(spriteNameOrImage)
    CCNode.init(self)
    CCRGBAMixin.init(self)
    self:setTexture(spriteNameOrImage)
    self:setAnchor(0.5, 0.5)
    self.flipX_ = false
    self.flipY_ = false
    
    -- currently only used for batch node;
    -- when Codea allows regular sprites to set tex rect, we'll need this all the time
    self.rect_ = ccRect(0, 0, self.size_.x, self.size_.y)
end

-- use CCSprite:alloc():initWithFrame(frameOrFrameName) to use this initializer
function CCSprite:initWithFrame(frameOrFrameName)
    CCNode.init(self)
    CCRGBAMixin.init(self)
    
    local frame
    if type(frameOrFrameName) == "string" then
        frame = CCSharedSpriteFrameCache():frameByName(frameOrFrameName)
    else
        frame = frameOrFrameName
    end
    
    local r = frame:rect()
    self:setTexture(frame:texture())
    self:setTextureRect(r, frame:rotated(), r:size())
    self:setAnchor(0.5, 0.5)
    self.flipX_ = false
    self.flipY_ = false
    
    return self 
end

-- alias for CCSprite.initWithFrame
CCSprite.initWithFrameName = CCSprite.initWithFrame

function CCSprite:setDisplayFrame(frameOrFrameName)
    local frame
    if type(frameOrFrameName) == "string" then
        frame = CCSharedSpriteFrameCache():frameByName(frameOrFrameName)
    else
        frame = frameOrFrameName
    end
    
    -- todo: handle rotated frames, and frames with offsets
    local r = frame:rect()
    self:setTexture(frame:texture())
    self:setTextureRect(r, frame:rotated(), r:size())
end

function CCSprite:draw()
    local c = self.color_
    tint(c.r, c.g, c.b, self.opacity_)
    
    spriteMode(CENTER)
    local s = self.size_
    local w = self.flipX_ and -s.x or s.x
    local h = self.flipY_ and -s.y or s.y
    
    if self.texture_ then sprite(self.texture_, s.x/2, s.y/2, w, h) end
    
    -- debug draw sprite rect
    --[[ 
    noFill()
    strokeWidth(2)
    stroke(255,128,128)
    rect(0, 0, s.x, s.y)
    --]]
end

function CCSprite:addChild(child, z, tag)
    CCNode.addChild(self, child, z, tag)
    
    local batchNode = self.batchNode_
    if batchNode then
        local index = batchNode:atlasIndexForChild(child, z)
        batchNode:insertChildInAtlas(child, index)
    end
end

function CCSprite:reorderChild(child, z)
    ccAssert(child)
    ccAssert(ccArrayContains(self.children_, child))
    
    if z == child.zOrder_ then return end
    
    if self.batchNode_ then
        self:removeChild(child, false)
        self:addChild(child, z)
    else
        CCNode.reorderChild(self, child, z)
    end
end

function CCSprite:removeChild(child, cleanup)
    if self.batchNode_ then
        self.batchNode_:removeSpriteFromAtlas(child)
    end
    
    CCNode.removeChild(self, child, cleanup)
end

function CCSprite:removeAllChildrenWithCleanup(cleanup)
    if self.batchNode_ then
        for i, child in ipairs(self.children_) do
            self.batchNode_:removeSpriteFromAtlas(child)
        end
    end
    
    CCNode.removeAllChildrenWithCleanup(self, cleanup)
end

--------------------
-- setters/getters
--------------------

function CCSprite:texture()
    return self.texture_
end

function CCSprite:setTexture(spriteNameOrImage)
    self.texture_ = spriteNameOrImage
    local w,h = spriteSize(spriteNameOrImage)
    
    -- for some reason images have to be scaled down by the scale factor
    if type(spriteNameOrImage) ~= "string" then
        w = w / ContentScaleFactor
        h = h / ContentScaleFactor
    end

    self:setSize(w, h)
end

function CCSprite:setColor(...)
    CCRGBAMixin.setColor(self, ...)
    self:updateColor()
end

function CCSprite:setOpacity(o)
    CCRGBAMixin.setOpacity(self, o)
    self:updateColor()
end

function CCSprite:setPosition(...)
    CCNode.setPosition(self, ...)
    if self.batchNode_ then self:setDirtyRecursively(true) end
end

function CCSprite:setRotation(r)
    CCNode.setRotation(self, r)
    if self.batchNode_ then self:setDirtyRecursively(true) end
end

function CCSprite:setScaleX(sx)
    CCNode.setScaleX(self, sx)
    if self.batchNode_ then self:setDirtyRecursively(true) end
end

function CCSprite:setScaleY(sy)
    CCNode.setScaleY(self, sy)
    if self.batchNode_ then self:setDirtyRecursively(true) end
end

function CCSprite:setScale(s)
    CCNode.setScale(self, s)
    if self.batchNode_ then self:setDirtyRecursively(true) end
end

function CCSprite:setAnchor(...)
    CCNode.setAnchor(self, ...)
    if self.batchNode_ then self:setDirtyRecursively(true) end
end

function CCSprite:setIgnoreAnchorForPosition(b)
    -- can't do this for sprites
    ccAssert(false)
    CCNode.setIgnoreAnchorForPosition(self, b)
end

function CCSprite:setVisible(v)
    CCNode.setVisible(self, v)
    if self.batchNode_ then self:setDirtyRecursively(true) end
end

function CCSprite:setFlipX(flip)
    if self.flipX_ ~= flip then
        self.flipX_ = flip
        
        -- only really need to set texture rect if batched...
        self:setTextureRect(self.rect_, false, self.size_)
    end
end

function CCSprite:setFlipY(flip)
    if self.flipY_ ~= flip then
        self.flipY_ = flip
        
        -- only really need to set texture rect if batched...      
        self:setTextureRect(self.rect_, false, self.size_)
    end
end

function CCSprite:setSize(...)
    local cs = self.size_
    cs.x, cs.y = ccVec2VA(...)
        
    local ap, app = self.anchor_, self.anchorInPoints_
    app.x, app.y = cs.x * ap.x, cs.y * ap.y
    self.isTransformDirty_, self.isInverseDirty_ = true, true    
end

--------------------
-- batch node stuff
--------------------
function CCSprite:setBatchNode(node)
    self.batchNode_ = node
    
    if node then
        self.transformToBatch_ = matrix()
        self.textureAtlas_ = node.textureAtlas_
        
        -- a side effect of quad() is that it lazily creates a quad
        -- let's just make sure it's created
        self:quad()
    else
        self.atlasIndex_ = nil
        self.textureAtlas_ = nil
        self.batchNode_ = nil
        self.batchTransformDirty_ = nil
        self.batchTransformDirtyR_ = nil
        self.batchColorDirty_ = nil
        self.batchTexRectDirty_ = nil
    
        -- currently we only use quads for batch nodes, since Codea's sprite() command
        -- draws our sprites otherwise
        self.quad_ = nil
        self.transformToBatch_ = nil
    end
end

function CCSprite:updateColor()    
    if self.quad_ then
        local q = self.quad_
        local r, g, b = self.color_:unpack()
        local a = self.opacity_
    
        self.quad_:setColor(1, r, g, b, a)
        self.quad_:setColor(2, r, g, b, a)
        self.quad_:setColor(3, r, g, b, a)
        self.quad_:setColor(4, r, g, b, a)        
    end

    local atlasIndex = self.atlasIndex_
    if atlasIndex then
        self.textureAtlas_:updateQuad(q, atlasIndex, false, true, false)
    else
        self.batchColorDirty_ = true        
    end
end

--function CCSprite:setTextureRect(r, rotated, untrimmedSize)
-- params: setTextureRect(rect, [rotated], [untrimmedSize])
function CCSprite:setTextureRect(r, rotated, untrimmedSize)
    ccAssert(r)
    local s, t, w, h = r:unpack()

    if rotated == nil then rotated = false end
    if untrimmedSize == nil then untrimmedSize = r:size() end
    
    self:setSize(untrimmedSize:unpack())
    
    -- create rect if it has not been created yet
    local selfRect = self.rect_
    if selfRect then
        selfRect:set(s, t, w, h)
    else
        self.rect_ = ccRect(s, t, w, h)
    end
    
    self:setTextureCoords(s, t, w, h)
    
    -- no need to do this really because setTextureCoords does it
    if self.batchNode_ then
        self.batchTexRectDirty_ = true
    else
        -- todo: set up the verts;
        -- haven't done this yet because sprite() doesn't support texture rects
    end
end

function CCSprite:quad()
    local quad = self.quad_
    if quad then return quad end
    
    local c, o = self.color_, self.opacity_
    quad = ccQuad(c.r, c.g, c.b, o, 0, 0, 1, 1)
    
    self.quad_ = quad
    return quad
end

function CCSprite:setTextureCoords(...)
    local s, t, tw, th = ccRect.va(...)
    
    local tex = self.textureAtlas_ and self.textureAtlas_:texture() or self.texture_
    if not tex then return end
    local rw, rh = spriteSize(tex)
    rw, rh = 1/rw, 1/rh        -- get reciprocals

    -- not sure why but, we have to transpose the top and bottom to make
    -- them work the same as they do on cocos2d-iphone.
    local left = s * rw
    local right = left + tw * rw
    local bottom = 1 - (t+th) * rh     --local bottom = t*rh --cocos2d-iphone version
    local top = bottom + th*rh

    if self.flipX_ then left, right = right, left end
    if self.flipY_ then top, bottom = bottom, top end
    
    self:quad():setTextureRect(left, bottom, right, top)
    
    self.batchTexCoordDirty_ = true;
end

-- actually updates the entire quad...
function CCSprite:updateTransform()
    local batchNode = self.batchNode_
    
    -- only valid when rendered by a CCSpriteBatchNode
    ccAssert(batchNode)
    
    local doXform = self.batchTransformDirty_
    local doColor = self.batchColorDirty_
    local doTC = self.batchTexRectDirty_
    
    if doXform then
        local p = self.parent_
        
        local visible = self.visible_
        
        if not visible or (p and p ~= batchNode and p.shouldBeHidden_) then
            self.textureAtlas_:hideQuad(self.atlasIndex_)
            self.shouldBeHidden_ = true
        else
            self.shouldBeHidden_ = false
            
            if not p or p == batchNode then
                self.transformToBatch_ = self:nodeToParentTransform()
            else
                -- todo: assert that parent is a CCSprite
                self.transformToBatch_ = self:nodeToParentTransform() * p.transformToBatch_
            end
            
            local bxf = self.transformToBatch_
            local x1, y1, w, h = 0, 0, self.rect_.w, self.rect_.h
            
            local x2 = x1 + w
            local y2 = y1 + h
            local x = bxf[13]
            local y = bxf[14]
            
            local cr = bxf[1]
            local sr = bxf[2]
            local cr2 = bxf[6]
            local sr2 = -bxf[5]

            local ax = x
            local ay = y
            local bx = x2 * cr + x
            local by = x2 * sr + y
            local cx = x2 * cr - y2 * sr2 + x
            local cy = x2 * sr + y2 * cr2 + y
            local dx = -y2 * sr2 + x
            local dy = y2 * cr2 + y            
                                    
            -- when I add sprite sheet support, x1 and y1 will be offsets
            --[[
            local ax = x1 * cr - y1 * sr2 + x
            local ay = x1 * sr + y1 * cr2 + y
            
            local bx = x2 * cr - y1 * sr2 + x
            local by = x2 * sr + y1 * cr2 + y
            
            local cx = x2 * cr - y2 * sr2 + x
            local cy = x2 * sr + y2 * cr2 + y
            
            local dx = x1 * cr - y2 * sr2 + x
            local dy = x1 * sr + y2 * cr2 + y
            --]]
            
            -- todo: add a setRect method to ccQuad
            local q = self:quad()
            q:setVertex(1, dx, dy)
            q:setVertex(2, ax, ay)
            q:setVertex(3, bx, by)
            q:setVertex(4, cx, cy)
        end
        
        self.batchTransformDirty_ = false        
        self.batchTransformDirtyR_ = false
    end
    
    if not self.shouldBeHidden_ and (doXform or doColor or doTC) then
        self.textureAtlas_:updateQuad(self:quad(), self.atlasIndex_, doXform, doColor, doTC)
        
        self.batchColorDirty_ = false
        self.batchTexRectDirty_ = false 
    end
    
    ccArrayForEach(self.children_, "updateTransform")
    
    -- debug draw quad
    --[[
        pushStyle()
        local q = self:quad()
        local tlx, tly = q:vertex(1)
        local blx, bly = q:vertex(2)
        local brx, bry = q:vertex(3)
        local trx, try = q:vertex(4)
        fill()
        stroke(255, 0, 0)
        strokeWidth(4)
        line(tlx, tly, blx, bly)
        line(blx, bly, brx, bry)
        line(brx, bry, trx, try)
        line(trx, try, tlx, tly)
        popStyle()
    --]]
end

function CCSprite:setDirtyRecursively(b)
    if self.batchNode_ and not self.batchTransformDirtyR_ then
        self.batchTransformDirty_ = b
        self.batchTransformDirtyR_ = b
    
        for i, child in ipairs(self.children_) do
            child:setDirtyRecursively(b)
        end
    end
end