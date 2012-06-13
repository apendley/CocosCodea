--CCProtocol

-----------------------------------------------------------
-- CCRGBAProtocol
--
-- includers must forward init to CCRGBAProtocol
-----------------------------------------------------------
CCRGBAProtocol = {}

ccPropColor{CCRGBAProtocol, "color"}
ccPropColor{CCRGBAProtocol, "color", "color_"}

function CCRGBAProtocol:init(...)
    self.color_ = ccc4(ccc4VA(...))
end

function CCRGBAProtocol:setOpacity(o)
    self.color_.a = o
end

function CCRGBAProtocol:opacity()
    return self.color_.a
end

-----------------------------------------------------------------------
-- CCTargetedTouchProtocol
--
-- includers must forward init, onEnter, and onExit to CCRGBAProtocol
--
-- * includer should implement registerWithTouchDispatcher for not-default
--   priority or of it doesn't want to swallow touches
--
-- * include must implement either ccTouched or ccTouchBegan, with
--   ccTouched having precedence if implemented
-----------------------------------------------------------------------
CCTargetedTouchProtocol = {}

ccProp{CCTargetedTouchProtocol, "isTouchEnabled", mode="r"}

function CCTargetedTouchProtocol:init()
    self.isTouchEnabled_ = false
end

function CCTargetedTouchProtocol:onEnter()
    if self.isTouchEnabled_ then
        self:registerWithTouchDispatcher()
    end
end

function CCTargetedTouchProtocol:onExit()
    if self.isTouchEnabled_ then
        CCSharedDirector():touchDispatcher():removeDelegate(self)
    end
end

function CCTargetedTouchProtocol:registerWithTouchDispatcher()
    CCSharedDirector():touchDispatcher():addTargetedDelegate(self, 0, true)
end

function CCTargetedTouchProtocol:setTouchEnabled(enabled)
    if self.isTouchEnabled_ ~= enabled then
        self.isTouchEnabled_ = enabled
        if self.isRunning_ then
            if enabled then 
                self:registerWithTouchDispatcher()
            else 
                CCSharedDirector():touchDispatcher():removeDelegate(self)
            end
        end
    end
end

function CCTargetedTouchProtocol:ccTouchBegan(touch)
    return false
end

-----------------------------------------------------------------------
-- CCLabelProtocol
-----------------------------------------------------------------------
CCLabelProtocol = {}

ccProp{CCLabelProtocol, "string", "labelString_"}

function CCLabelProtocol:init(str)
    self:setString(str)
end


-----------------------------------------------------------------------
-- CCMenuItemLabelProtocol
-- this class implements CCRGBAProtocol, so shouldn't include both.
-----------------------------------------------------------------------
CCMenuItemLabelProtocol = {}

local kCCZoomActionTag = 19191919

ccProp{CCMenuItemLabelProtocol, "label", mode="r"}
ccProp{CCMenuItemLabelProtocol, "disabledColor"}


function CCMenuItemLabelProtocol:init(label)
    self:setLabel(label)    
    self.originalScale = 1
    self.colorBackup = ccc3(255, 255, 255)
    self.disabledColor_ = ccc3(126, 126, 126)
end

function CCMenuItemLabelProtocol:setLabel(label)
    ccAssert(label ~= nil)
    
    if self.label_ ~= label then
        if self.label_ then self:removeChild(self.label_, true) end
        self:addChild(label)
        self.label_ = label
        label:setAnchorPoint(0, 0)
        self:updateContentSize()
    end
end

function CCMenuItemLabelProtocol:updateContentSize()
    self:setContentSize(self.label_:contentSize())
end

function CCMenuItemLabelProtocol:setString(str)
    self.label_:setString(str)
    self:updateContentSize()
end

function CCMenuItemLabelProtocol:activate()
    if self.isEnabled_ then
        -- careful, scales up self, not the label
        self:stopActionByTag(kCCZoomActionTag)
        self:setScale(self.originalScale)
    end
end

function CCMenuItemLabelProtocol:selected()
    if self.isEnabled_ then
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

function CCMenuItemLabelProtocol:unselected()
    if self.isEnabled_ then
        self:stopActionByTag(kCCZoomActionTag)
        local zoomAction = CCScaleTo(0.1, self.originalScale)
        zoomAction.tag = kCCZoomActionTag
        self:runAction(zoomAction)
    end
end

function CCMenuItemLabelProtocol:setEnabled(enabled)
    if self.isEnabled_ ~= enabled then
        local label = self.label_
        if enabled == false then
            self.colorBackup = label:color()
            label:setColor(self.disabledColor_)
        else
            label:setColor(self.colorBackup)
        end
    end
end

function CCMenuItemLabelProtocol:setOpacity(o)
    self.label_:setOpacity(o)
end
    
function CCMenuItemLabelProtocol:opacity()
    return self.label_:opacity()
end

function CCMenuItemLabelProtocol:setColor(...)
    self.label_:setColor(...)
end

function CCMenuItemLabelProtocol:color()    
    return self.label_:color()
end

function CCMenuItemLabelProtocol:setColor4(...)
    self.label_:setColor4(...)
end

function CCMenuItemLabelProtocol:color4()
    return self.label_:color4()
end

function CCMenuItemLabelProtocol:cleanup()
    self.label_ = nil
end

-----------------------------------------------------------------------
-- CCMenuItemSpriteProtocol
-- this class implements CCRGBAProtocol, so shouldn't include both.
-----------------------------------------------------------------------
CCMenuItemSpriteProtocol = {}    

ccProp{CCMenuItemSpriteProtocol, "normalImage", mode="r"}
ccProp{CCMenuItemSpriteProtocol, "selectedImage", mode="r"}
ccProp{CCMenuItemSpriteProtocol, "disabledImage", mode="r"}
    
function CCMenuItemSpriteProtocol:init(normalSprite, selectedSprite, disabledSprite)
    ccAssert(normalSprite)
    self:setNormalImage(normalSprite)
    self:setSelectedImage(selectedSprite)
    self:setDisabledImage(disabledSprite)
    self:updateContentSize()
end
                
function CCMenuItemSpriteProtocol:cleanup()
    self.normalImage_ = nil
    self.selectedImage_ = nil
    self.disabledImage_ = nil
end                        

function CCMenuItemSpriteProtocol:setNormalImage(img)
    if img ~= self.normalImage_ then
        ccAssert(img)        
        img:setAnchorPoint(0, 0)
        self:removeChild(self.normalImage_, true)
        self:addChild(img)
        self.normalImage_ = img
        self:updateContentSize()
        self:updateImagesVisibility()
    end
end

function CCMenuItemSpriteProtocol:setSelectedImage(img)
    if img ~= self.selectedImage_ then
        if self.selectedImage_ then self:removeChild(self.selectedImage_, true) end
        
        if img then
            img:setAnchorPoint(0, 0)
            self:addChild(img)
            self.selectedImage_ = img
        else
            self.selectedImage_ = nil
        end
        
        self:updateImagesVisibility()        
    end    
end

function CCMenuItemSpriteProtocol:setDisabledImage(img)
    if img ~= self.disabledImage_ then
        if self.disabledImage_ then self:removeChild(self.disabledImage_, true) end        
        
        if img then
            img:setAnchorPoint(0, 0)
            self:addChild(img)
            self.disabledImage_ = img
        else
            self.disabledImage_ = nil
        end
        
        self:updateImagesVisibility()        
    end    
end

function CCMenuItemSpriteProtocol:updateImagesVisibility()
    local ni = self.normalImage_
    local si = self.selectedImage_
    local di = self.disabledImage_
        
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

function CCMenuItemSpriteProtocol:updateContentSize()
    return self:setContentSize(self.normalImage_:contentSize())
end

function CCMenuItemSpriteProtocol:setOpacity(o)
    local ni = self.normalImage_
    local si = self.selectedImage_
    local di = self.disabledImage_
    
    if ni then ni:setOpacity(o) end
    if si then si:setOpacity(o) end
    if di then di:setOpacity(o) end
end

function CCMenuItemSpriteProtocol:setColor(...)
    local ni = self.normalImage_
    local si = self.selectedImage_
    local di = self.disabledImage_
    
    if ni then ni:setColor(...) end
    if si then si:setColor(...) end
    if di then di:setColor(...) end
end

function CCMenuItemSpriteProtocol:setColor4(...)
    local ni = self.normalImage_
    local si = self.selectedImage_
    local di = self.disabledImage_
    
    if ni then ni:setColor4(...) end
    if si then si:setColor4(...) end
    if di then di:setColor4(...) end    
end

function CCMenuItemSpriteProtocol:color()
    return self.normalImage_:color()
end

function CCMenuItemSpriteProtocol:opacity()
    return self.normalImage_:opacity()
end

function CCMenuItemSpriteProtocol:color4()
    return self.normalImage_:color4()
end

function CCMenuItemSpriteProtocol:selected()
    local ni = self.normalImage_
    local si = self.selectedImage_
    local di = self.disabledImage_   
       
    if si then
        ni:setVisible(false)
        si:setVisible(true)
        if di then di:setVisible(false) end
    else
        ni:setVisible(true)
        if di then di:setVisible(false) end
    end
end

function CCMenuItemSpriteProtocol:unselected()
    local ni = self.normalImage_
    local si = self.selectedImage_
    local di = self.disabledImage_
    
    ni:setVisible(true)
    if si then si:setVisible(false) end
    if di then di:setVisible(false) end
end

function CCMenuItemSpriteProtocol:setEnabled(enabled)
    if self.isEnabled_ ~= enabled then
        self:updateImagesVisibility()
    end
end
