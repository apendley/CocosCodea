--CCMenuItem
CCMenuItem = CCClass(CCNode)

function CCMenuItem:init(fn)
    CCNode.init(self)
    self:setAnchorPoint(0.5, 0.5)
    self.fn_ = fn
    self.isEnabled_ = true
    self.isSelected_ = false
end
function CCMenuItem:cleanup()
    self.fn_ = nil
    CCNode.cleanup(self)
end

function CCMenuItem:isEnabled()
    return self.isEnabled_
end

function CCMenuItem:setEnabled(enabled)
    self.isEnabled_ = enabled
end

function CCMenuItem:isSelected()
    return self.isSelected_
end

function CCMenuItem:selected()
    self.isSelected_ = true
end

function CCMenuItem:unselected()
    self.isSelected_ = false
end

function CCMenuItem:activate()
    if self.isEnabled_ and self.fn_ then
        self:fn_()
    end
end

function CCMenuItem:rect()
    local pos = self:position()
    local cs = self:contentSize()
    local ap = self:anchorPoint()
    return ccRect(pos.x-cs.x*ap.x, pos.y-cs.y*ap.y, cs.x, cs.y)
end

function CCMenuItem:setFunction(fn)
    self.fn_ = fn
end


-------------------
-- CCMenuItemSprite
-------------------
CCMenuItemSprite = CCClass(CCMenuItem):include(CCRGBAProtocol)

function CCMenuItemSprite:init(normalSprite, selectedSprite, disabledSprite, fn)
    CCMenuItem.init(self, fn)
    CCRGBAProtocol.init(self)
    self:setNormalImage(normalSprite)
    self:setSelectedImage(selectedSprite)
    self:setDisabledImage(disabledSprite)
    self:setContentSize(normalSprite:contentSize())
end

function CCMenuItemSprite:cleanup()
    self.normalImage = nil
    self.selectedImage = nil
    self.disabledImage = nil
    CCMenuItem.cleanup(self)
end

function CCMenuItemSprite:setNormalImage(img)
    if img ~= self.normalImage then
        assert(img)        
        img:setAnchorPoint(0, 0)
        self:removeChild(self.normalImage, true)
        self:addChild(img)
        self.normalImage = img
        self:setContentSize(img:contentSize())
        self:updateImagesVisibility()
    end
end

function CCMenuItemSprite:setSelectedImage(img)
    if img ~= self.selectedImage then
        if self.selectedImage then self:removeChild(self.selectedImage, true) end        
        
        if img then
            img:setAnchorPoint(0, 0)
            self:addChild(img)
            self.selectedImage = img
        else
            self.selectedImage = nil
        end
        
        self:updateImagesVisibility()        
    end    
end

function CCMenuItemSprite:setDisabledImage(img)
    if img ~= self.disabledImage then
        if self.disabledImage then self:removeChild(self.disabledImage, true) end        
        
        if img then
            img:setAnchorPoint(0, 0)
            self:addChild(img)
            self.disabledImage = img
        else
            self.disabledImage = nil
        end
        
        self:updateImagesVisibility()        
    end    
end

function CCMenuItemSprite:setOpacity(o)
    local ni = self.normalImage
    local si = self.selectedImage
    local di = self.disabledImage
    
    if ni then ni:setOpacity(o) end
    if si then si:setOpacity(o) end
    if di then di:setOpacity(o) end
end

function CCMenuItemSprite:setColor(c)
    local ni = self.normalImage
    local si = self.selectedImage
    local di = self.disabledImage
    
    if ni then ni:setColor(c) end
    if si then si:setColor(c) end
    if di then di:setColor(c) end
end

function CCMenuItemSprite:setColorRaw(c)
    local ni = self.normalImage
    local si = self.selectedImage
    local di = self.disabledImage
    
    if ni then ni:setColorRaw(c) end
    if si then si:setColorRaw(c) end
    if di then di:setColorRaw(c) end    
end

function CCMenuItemSprite:color()
    return self.normalImage:color()
end

function CCMenuItemSprite:opacity()
    return self.normalImage:opacity()
end

function CCMenuItemSprite:colorRaw()
    return self.normalImage:colorRaw()
end

function CCMenuItemSprite:selected()
    CCMenuItem.selected(self)
    
    local ni = self.normalImage
    local si = self.selectedImage
    local di = self.disabledImage    
    
    if si then
        ni:setVisible(false)
        si:setVisible(true)
        if di then di:setVisible(false) end
    else
        ni:setVisible(true)
        if di then di:setVisible(false) end
    end
end

function CCMenuItemSprite:unselected()
    local ni = self.normalImage
    local si = self.selectedImage
    local di = self.disabledImage
    
    ni:setVisible(true)
    if si then si:setVisible(false) end
    if di then di:setVisible(false) end
end

function CCMenuItemSprite:setEnabled(enabled)
    if self.isEnabled_ ~= enabled then
        CCMenuItem.setEnabled(enabled)
        self:updateImagesVisibility()
    end
end

function CCMenuItemSprite:updateImagesVisibility()
    local ni = self.normalImage
    local si = self.selectedImage
    local di = self.disabledImage
        
    if self.isEnabled_ then
        ni:setVisible(true)
        if si then si:setVisible(false) end
        if di then di:setVisible(false) end
    else
        if di then
            ni:setVisible(false)
            if si then si:setVisible(false) end
            di:setVisible(true)
        else
            ni:setVisible(true)
            if si then si:setVisible(false) end
            if di then di:setVisible(false) end        
        end
    end
end