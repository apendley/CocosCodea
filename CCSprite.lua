CCSprite = CCClass(CCNode):include(CCRGBAProtocol)

function CCSprite:init(spriteName)
    CCNode.init(self)
    CCRGBAProtocol.init(self)    
    self:setSprite(spriteName)
    self:setAnchorPoint(0.5, 0.5)
end

function CCSprite:draw()
    --pushStyle()
    local c = self.color_
    tint(c.r, c.g, c.b, c.a)
    spriteMode(CORNER)
    if self.sprite_ then sprite(self.sprite_) end
    --popStyle()
end

--------------------
-- setters/getters
--------------------

function CCSprite:sprite(_)
    assert(_ == nil)
    return self.sprite_
end

function CCSprite:setSprite(spriteName)
    self.sprite_ = spriteName
    self:setContentSize(spriteSize(spriteName))    
end