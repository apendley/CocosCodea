--CCMixin

-----------------------------------------------------------
-- CCRGBAMixin
--
-- includers must forward init to CCRGBAMixin
-----------------------------------------------------------
CCRGBAMixin = {}

ccSynthColor4{CCRGBAMixin, "color4", ivar="color_"}
ccSynthColor{CCRGBAMixin, "color"}

function CCRGBAMixin:init(...)
    self.color_ = ccc4(ccc4VA(...))
end

function CCRGBAMixin:setOpacity(o)
    self.color_.a = o
end

function CCRGBAMixin:opacity()
    return self.color_.a
end

-----------------------------------------------------------------------
-- CCTargetedTouchMixin
--
-- includers must forward init, onEnter, and onExit to CCRGBAMixin
--
-- * includer should implement registerWithTouchDispatcher for not-default
--   priority or of it doesn't want to swallow touches
--
-- * include must implement either ccTouched or ccTouchBegan, with
--   ccTouched having precedence if implemented
-----------------------------------------------------------------------
CCTargetedTouchMixin = {}

ccSynth{CCTargetedTouchMixin, "isTouchEnabled", mode="r"}

function CCTargetedTouchMixin:init()
    self.isTouchEnabled_ = false
end

function CCTargetedTouchMixin:onEnter()
    if self.isTouchEnabled_ then
        self:registerWithTouchDispatcher()
    end
end

function CCTargetedTouchMixin:onExit()
    if self.isTouchEnabled_ then
        CCSharedDirector():touchDispatcher():removeDelegate(self)
    end
end

function CCTargetedTouchMixin:registerWithTouchDispatcher()
    CCSharedDirector():touchDispatcher():addTargetedDelegate(self, 0, true)
end

function CCTargetedTouchMixin:setTouchEnabled(enabled)
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

function CCTargetedTouchMixin:ccTouchBegan(touch)
    return false
end

-----------------------------------------------------------------------
-- CCLabelMixin
-----------------------------------------------------------------------
CCLabelMixin = {}

ccSynth{CCLabelMixin, "string", "labelString_"}

function CCLabelMixin:init(str)
    self:setString(str)
end


-----------------------------------------------------------------------
-- CCMenuItemLabelMixin
-- this class implements CCRGBAMixin, so shouldn't include both.
-----------------------------------------------------------------------
CCMenuItemLabelMixin = {}

local kCCZoomActionTag = 19191919

ccSynth{CCMenuItemLabelMixin, "label", mode="r"}
ccSynth{CCMenuItemLabelMixin, "disabledColor"}


function CCMenuItemLabelMixin:init(label)
    self:setLabel(label)    
    self.originalScale = 1
    self.colorBackup = ccc3(255, 255, 255)
    self.disabledColor_ = ccc3(126, 126, 126)
end

function CCMenuItemLabelMixin:setLabel(label)
    ccAssert(label ~= nil)
    
    if self.label_ ~= label then
        if self.label_ then self:removeChild(self.label_, true) end
        self:addChild(label)
        self.label_ = label
        label:setAnchorPoint(0, 0)
        self:updateContentSize()
    end
end

function CCMenuItemLabelMixin:updateContentSize()
    self:setContentSize(self.label_:contentSize())
end

function CCMenuItemLabelMixin:setString(str)
    self.label_:setString(str)
    self:updateContentSize()
end

function CCMenuItemLabelMixin:activate()
    if self.isEnabled_ then
        -- careful, scales up self, not the label
        self:stopActionByTag(kCCZoomActionTag)
        self:setScale(self.originalScale)
    end
end

function CCMenuItemLabelMixin:selected()
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

function CCMenuItemLabelMixin:unselected()
    if self.isEnabled_ then
        self:stopActionByTag(kCCZoomActionTag)
        local zoomAction = CCScaleTo(0.1, self.originalScale)
        zoomAction.tag = kCCZoomActionTag
        self:runAction(zoomAction)
    end
end

function CCMenuItemLabelMixin:setEnabled(enabled)
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

function CCMenuItemLabelMixin:setOpacity(o)
    self.label_:setOpacity(o)
end
    
function CCMenuItemLabelMixin:opacity()
    return self.label_:opacity()
end

function CCMenuItemLabelMixin:setColor(...)
    self.label_:setColor(...)
end

function CCMenuItemLabelMixin:color()    
    return self.label_:color()
end

function CCMenuItemLabelMixin:setColor4(...)
    self.label_:setColor4(...)
end

function CCMenuItemLabelMixin:color4()
    return self.label_:color4()
end

function CCMenuItemLabelMixin:cleanup()
    self.label_ = nil
end

-----------------------------------------------------------------------
-- CCMenuItemSpriteMixin
-- this class implements CCRGBAMixin, so shouldn't include both.
-----------------------------------------------------------------------
CCMenuItemSpriteMixin = {}    

ccSynth{CCMenuItemSpriteMixin, "normalImage", mode="r"}
ccSynth{CCMenuItemSpriteMixin, "selectedImage", mode="r"}
ccSynth{CCMenuItemSpriteMixin, "disabledImage", mode="r"}
    
function CCMenuItemSpriteMixin:init(normalSprite, selectedSprite, disabledSprite)
    ccAssert(normalSprite)
    self:setNormalImage(normalSprite)
    self:setSelectedImage(selectedSprite)
    self:setDisabledImage(disabledSprite)
    self:updateContentSize()
end
                
function CCMenuItemSpriteMixin:cleanup()
    self.normalImage_ = nil
    self.selectedImage_ = nil
    self.disabledImage_ = nil
end                        

function CCMenuItemSpriteMixin:setNormalImage(img)
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

function CCMenuItemSpriteMixin:setSelectedImage(img)
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

function CCMenuItemSpriteMixin:setDisabledImage(img)
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

function CCMenuItemSpriteMixin:updateImagesVisibility()
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

function CCMenuItemSpriteMixin:updateContentSize()
    return self:setContentSize(self.normalImage_:contentSize())
end

function CCMenuItemSpriteMixin:setOpacity(o)
    local ni = self.normalImage_
    local si = self.selectedImage_
    local di = self.disabledImage_
    
    if ni then ni:setOpacity(o) end
    if si then si:setOpacity(o) end
    if di then di:setOpacity(o) end
end

function CCMenuItemSpriteMixin:setColor(...)
    local ni = self.normalImage_
    local si = self.selectedImage_
    local di = self.disabledImage_
    
    if ni then ni:setColor(...) end
    if si then si:setColor(...) end
    if di then di:setColor(...) end
end

function CCMenuItemSpriteMixin:setColor4(...)
    local ni = self.normalImage_
    local si = self.selectedImage_
    local di = self.disabledImage_
    
    if ni then ni:setColor4(...) end
    if si then si:setColor4(...) end
    if di then di:setColor4(...) end    
end

function CCMenuItemSpriteMixin:color()
    return self.normalImage_:color()
end

function CCMenuItemSpriteMixin:opacity()
    return self.normalImage_:opacity()
end

function CCMenuItemSpriteMixin:color4()
    return self.normalImage_:color4()
end

function CCMenuItemSpriteMixin:selected()
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

function CCMenuItemSpriteMixin:unselected()
    local ni = self.normalImage_
    local si = self.selectedImage_
    local di = self.disabledImage_
    
    ni:setVisible(true)
    if si then si:setVisible(false) end
    if di then di:setVisible(false) end
end

function CCMenuItemSpriteMixin:setEnabled(enabled)
    if self.isEnabled_ ~= enabled then
        self:updateImagesVisibility()
    end
end
