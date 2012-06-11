CCSprite = CCClass(CCNode):include(CCRGBAProtocol)

function CCSprite:init(spriteNameOrImage)
    CCNode.init(self)
    CCRGBAProtocol.init(self)    
    self:setSprite(spriteNameOrImage)
    self:setAnchorPoint(0.5, 0.5)
end

function CCSprite:draw()
    local c = self.color_
    tint(c.r, c.g, c.b, c.a)
    spriteMode(CORNER)
    
    local s = self.contentSize_    
    if self.sprite_ then sprite(self.sprite_, 0, 0, s.x, s.y) end
    
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
    assert(_ == nil)
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