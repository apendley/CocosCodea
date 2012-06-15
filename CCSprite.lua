CCSprite = CCClass(CCNode):include(CCRGBAMixin)

CCSprite:synth{"flipX"}
CCSprite:synth{"flipY"}

function CCSprite:init(spriteNameOrImage)
    CCNode.init(self)
    CCRGBAMixin.init(self)
    self:setSprite(spriteNameOrImage)
    self:setAnchorPoint(0.5, 0.5)
    self.flipX_ = false
    self.flipY_ = false
end

function CCSprite:setContentSize(...)
    
    local cs = self.contentSize_
    cs.x, cs.y = ccVec2VA(...)
        
    -- see ccConfig
    if CC_ENABLE_CODEA_2X_MODE then
        local csf = ContentScaleFactor
        cs.x, cs.y = cs.x * csf, cs.y * csf
    end            
        
    local ap, app = self.anchorPoint_, self.anchorPointInPoints_
    app.x, app.y = cs.x * ap.x, cs.y * ap.y
    self.isTransformDirty_, self.isInverseDirty_ = true, true    
end

function CCSprite:draw()
    local c = self.color_
    tint(ccc4Unpack(self.color_))
    
    --spriteMode(CORNER)
    --if self.sprite_ then sprite(self.sprite_, 0, 0, s.x, s.y) end
    
    spriteMode(CENTER)
    local s = self.contentSize_    
    local w = self.flipX_ and -s.x or s.x
    local h = self.flipY_ and -s.y or s.y
    
    if self.sprite_ then sprite(self.sprite_, s.x/2, s.y/2, w, h) end
    
    -- debug draw sprite rect
    --[[ 
    noFill()
    strokeWidth(2)
    stroke(255,128,128)
    rect(0, 0, s.x, s.y)
    --]]
end

--------------------
-- setters/getters
--------------------

function CCSprite:sprite(_)
    ccAssert(_ == nil)
    return self.sprite_
end

function CCSprite:setSprite(spriteNameOrImage)
    self.sprite_ = spriteNameOrImage
    
    local w,h = spriteSize(spriteNameOrImage)
    
    -- for some reason images have to be scaled down by the scale factor
    if type(spriteNameOrImage) ~= "string" then
        w = w / ContentScaleFactor
        h = h / ContentScaleFactor
    end

    self:setContentSize(w, h)
end