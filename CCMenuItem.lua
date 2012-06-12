--CCMenuItem
CCMenuItem = CCClass(CCNode)

ccProp{CCMenuItem, "isEnabled", setter="setEnabled"}
ccProp{CCMenuItem, "isSelected", mode="r"}
ccProp{CCMenuItem, "handler"}

function CCMenuItem:init()
    CCNode.init(self)
    self:setAnchorPoint(0.5, 0.5)
    self.isEnabled_ = true
    self.isSelected_ = false
end
function CCMenuItem:cleanup()
    self.handler_ = nil
    CCNode.cleanup(self)
end

function CCMenuItem:selected()
    self.isSelected_ = true
end

function CCMenuItem:unselected()
    self.isSelected_ = false
end

function CCMenuItem:activate()
    if self.isEnabled_ and self.handler_ then
        self:handler_()
    end
end

function CCMenuItem:rect()
    local pos = self:position()
    local cs = self:contentSize()
    local ap = self:anchorPoint()
    return ccRect(pos.x-cs.x*ap.x, pos.y-cs.y*ap.y, cs.x, cs.y)
end

-- debug draw sprite rect
--[[ 
function CCMenuItem:draw()
    CCNode.draw(self)
    
    noFill()
    strokeWidth(2)
    stroke(255,128,128)
    local s = self:contentSize()
    rect(0, 0, s.x, s.y)
end
--]]    

-------------------
-- CCMenuItemSprite
-------------------
CCMenuItemSprite = CCClass(CCMenuItem):include(CCRGBAProtocol)

function CCMenuItemSprite:init(normalSprite, selectedSprite, disabledSprite)
    CCMenuItem.init(self)
    --CCRGBAProtocol.init(self)
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
        ccAssert(img)        
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

function CCMenuItemSprite:setColor3(...)
    local ni = self.normalImage
    local si = self.selectedImage
    local di = self.disabledImage
    
    if ni then ni:setColor3(...) end
    if si then si:setColor3(...) end
    if di then di:setColor3(...) end
end

function CCMenuItemSprite:setColor(...)
    local ni = self.normalImage
    local si = self.selectedImage
    local di = self.disabledImage
    
    if ni then ni:setColor(...) end
    if si then si:setColor(...) end
    if di then di:setColor(...) end    
end

function CCMenuItemSprite:color3()
    return self.normalImage:color3()
end

function CCMenuItemSprite:opacity()
    return self.normalImage:opacity()
end

function CCMenuItemSprite:color()
    return self.normalImage:color()
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

-- todo: allow changing the function

--------------------
-- CCMenuItemLabel
--------------------
CCMenuItemLabel = CCClass(CCMenuItem):include(CCRGBAProtocol)

local kCCZoomActionTag = 19191919

ccProp{CCMenuItemLabel, "label", mode="r"}
ccProp{CCMenuItemLabel, "disabledColor"}

function CCMenuItemLabel:init(label)
    CCMenuItem.init(self, fn)
    self:setLabel(label)    
    self.originalScale = 1
    self.colorBackup = ccColor(255, 255, 255)
    self.disabledColor_ = ccColor(126, 126, 126)
end

function CCMenuItemLabel:setLabel(label)
    ccAssert(label ~= nil)
    
    if self.label_ ~= label then
        if self.label_ then self:removeChild(self.label_, true) end
        self:addChild(label)
        self.label_ = label
        label:setAnchorPoint(0, 0)
        self:setContentSize(label:contentSize())
    end
end

function CCMenuItemLabel:setString(str)
    self.label_:setString(str)
    self:setContentSize(self.label_:contentSize())
end

function CCMenuItemLabel:activate()
    if self.isEnabled_ then
        self:stopAllActions()
        self:setScale(self.originalScale)
        CCMenuItem.activate(self)
    end
end

function CCMenuItemLabel:selected()
    if self.isEnabled_ then
        CCMenuItem.selected(self)
        
        local action = self:getActionByTag(kCCZoomActionTag)
        if action then
            self:stopAction(action)
        else
            self.originalScale = self:scale()
        end
        
        local zoomAction = CCScaleTo(0.1, self.originalScale * 1.2)
        zoomAction.tag = kCCZoomActionTag
        self:runAction(zoomAction)
    end
end

function CCMenuItemLabel:unselected()
    if self.isEnabled_ then
        CCMenuItem.unselected(self)
        self:stopActionByTag(kCCZoomActionTag)
        local zoomAction = CCScaleTo(0.1, self.originalScale)
        zoomAction.tag = kCCZoomActionTag
        self:runAction(zoomAction)
    end
end

function CCMenuItemLabel:setEnabled(enabled)
    if self.isEnabled_ ~= enabled then
        local label = self.label
        if enabled == false then
            self.colorBackup = label:color3()
            label:setColor3(self.disabledColor_)
        else
            label:setColor3(self.colorBackup)
        end
    end
    
    CCMenuItem.setEnabled(self, enabled)
end

function CCMenuItemLabel:setOpacity(o)
    self.label_:setOpacity(o)
end

function CCMenuItemLabel:opacity()
    return self.label_:opacity()
end

function CCMenuItemLabel:setColor3(...)
    self.label_:setColor3(...)
end

function CCMenuItemLabel:color3(c)
    return self.label_:color3()
end

function CCMenuItemLabel:setColor(...)
    self.label_:setColor(...)
end

function CCMenuItemLabel:color()
    return self.label_:color()
end

function CCMenuItemLabel:cleanup()
    CCMenuItem.cleanup(self)
    self.label_ = nil
end

--------------------
-- CCMenuItemFont
--------------------
CCMenuItemFont = CCClass(CCMenuItemLabel)

ccProp{CCMenuItemFont, "fontSize", mode="r"}
ccProp{CCMenuItemFont, "fontName", mode="r"}
ccProp{CCMenuItemFont, "alignment", mode="r"}
ccProp{CCMenuItemFont, "wrapWidth", mode="r"}

function CCMenuItemFont:init(str, fontName, pointSize, align, wrapWidth)
    local label = CCLabelTTF(str, fontName, pointSize, align, wrapWidth)
    CCMenuItemLabel.init(self, label, fn)
    
    self.fontName_ = label:fontName()
    self.fontSize_ = label:fontSize()
    self.alignment_ = label:alignment()
    self.wrapWidth_ = label:wrapWidth()
end

function CCMenuItemFont:updateLabel()
    local label = self:label()
    label:setFontName(self.fontName_)
    label:setFontSize(self.fontSize_)
    label:setAlignment(self.alignment_)
    label:setWrapWidth(self.wrapWidth_)
    self:setContentSize(label:contentSize())
end

function CCMenuItemFont:setFontSize(size)
    self.fontSize_ = size
    self:updateLabel()
end

function CCMenuItemFont:setFontName(fontName)
    self.fontName_ = fontName
    self:updateLabel()
end

function CCMenuItemFont:setAlignment(align)
    self.alignment_ = align
    self:updateLabel()
end

function CCMenuItemFont:setWrapWidth(width)
    self.wrapWidth_ = width
    self:updateLabel()
end