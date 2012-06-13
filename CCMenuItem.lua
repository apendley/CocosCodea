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
CCMenuItemSprite = CCClass(CCMenuItem):include(CCMenuItemSpriteProtocol)

function CCMenuItemSprite:init(normalSprite, selectedSprite, disabledSprite)
    CCMenuItem.init(self)
    CCMenuItemSpriteProtocol.init(self, normalSprite, selectedSprite, disabledSprite)
end

function CCMenuItemSprite:cleanup()
    CCMenuItem.cleanup(self)
    CCMenuItemSpriteProtocol.cleanup(self)
end

function CCMenuItemSprite:selected()
    CCMenuItem.selected(self)
    CCMenuItemSpriteProtocol.selected(self)
end

function CCMenuItemSprite:unselected()
    CCMenuItem.unselected(self)
    CCMenuItemSpriteProtocol.unselected(self)
end

function CCMenuItemSprite:setEnabled(enabled)
    if self.isEnabled_ ~= enabled then
        CCMenuItem.setEnabled(self, enabled)
        CCMenuItemSpriteProtocol.setEnabled(self, enabled)
    end
end




--------------------
-- CCMenuItemLabel
--------------------
CCMenuItemLabel = CCClass(CCMenuItem):include(CCMenuItemLabelProtocol)

function CCMenuItemLabel:init(label)
    CCMenuItem.init(self)
    CCMenuItemLabelProtocol.init(self, label)
end

function CCMenuItemLabel:activate()
    if self.isEnabled_ then
        CCMenuItemLabelProtocol.activate(self)
        CCMenuItem.activate(self)
    end
end

function CCMenuItemLabel:selected()
    if self.isEnabled_ then
        CCMenuItem.selected(self)
        CCMenuItemLabelProtocol.selected(self)
    end
end

function CCMenuItemLabel:unselected()
    if self.isEnabled_ then
        CCMenuItem.unselected(self)
        CCMenuItemLabelProtocol.unselected(self)
    end
end

function CCMenuItemLabel:setEnabled(enabled)
    CCMenuItemLabelProtocol.setEnabled(self, enabled)
    CCMenuItem.setEnabled(self, enabled)
end

function CCMenuItemLabel:cleanup()
    CCMenuItem.cleanup(self)
    CCMenuItemLabelProtocol.cleanup(self)
end

----------------------------------------
-- CCMenuItemBackedLabel
----------------------------------------
CCMenuItemBackedLabel = CCClass(CCMenuItem)
CCMenuItemBackedLabel:include(CCMenuItemSpriteProtocol)
CCMenuItemBackedLabel:include(CCMenuItemLabelProtocol)

function CCMenuItemBackedLabel:init(label, normal, selected, disabled)
    assert(label and normal)
    CCMenuItem.init(self)
    CCMenuItemSpriteProtocol.init(self, normal, selected, disabled)    
    CCMenuItemLabelProtocol.init(self, label)    
    self:updateContentSize()
end

function CCMenuItemBackedLabel:updateContentSize()
    local img = self.normalImage_
    local label = self.label_

    local lw, lh
    if label then
        local cs = label:contentSize()
        lw, lh = cs.x, cs.y
    else
        lw, lh = 0, 0
    end
    
    local iw, ih
    if img then 
        local cs = img:contentSize()
        iw, ih = cs.x, cs.y
    else
        iw, ih = 0, 0
    end

    local w = math.max(iw, lw)
    local h = math.max(ih, lh)
    self:setContentSize(w, h)
    
    if label and img then
        local pos = img:contentSize()/2
        pos = pos - label:contentSize()/2
        label:setPosition(pos)
    end
end

function CCMenuItemBackedLabel:activate()
    if self.isEnabled_ then
        CCMenuItemLabelProtocol.activate(self)
        CCMenuItem.activate(self)
    end
end

function CCMenuItemBackedLabel:selected()
    if self.isEnabled_ then
        CCMenuItem.selected(self)
        CCMenuItemLabelProtocol.selected(self)
        CCMenuItemSpriteProtocol.selected(self)
    end
end

function CCMenuItemBackedLabel:unselected()
    if self.isEnabled_ then
        CCMenuItem.unselected(self)
        CCMenuItemLabelProtocol.unselected(self)
        CCMenuItemSpriteProtocol.unselected(self)    
    end
end

function CCMenuItemBackedLabel:setEnabled(enabled)
    CCMenuItemLabelProtocol.setEnabled(self, enabled)
    CCMenuItemSpriteProtocol.setEnabled(self, enabled)
    CCMenuItem.setEnabled(self, enabled)
end

function CCMenuItemBackedLabel:cleanup()
    CCMenuItem.cleanup(self)
    CCMenuItemLabelProtocol.cleanup(self)
    CCMenuItemSpriteProtocol.cleanup(self)
end

function CCMenuItemBackedLabel:setOpacity(o)
    CCMenuItemLabelProtocol.setOpacity(self, o)
    CCMenuItemSpriteProtocol.setOpacity(self, o)
end
    
function CCMenuItemBackedLabel:opacity()
    return CCMenuItemLabelProtocol.opacity(self)
end

function CCMenuItemBackedLabel:setColor(...)
    CCMenuItemLabelProtocol.setColor(self, ...)
    CCMenuItemSpriteProtocol.setColor(self, ...)
end

function CCMenuItemBackedLabel:color()    
    return CCMenuItemLabelProtocol.color(self)
end

function CCMenuItemBackedLabel:setColor4(...)
    CCMenuItemLabelProtocol.setColor4(self, ...)
    CCMenuItemSpriteProtocol.setColor4(self, ...)    
end

function CCMenuItemBackedLabel:color4()
    return CCMenuItemLabelProtocol.color4(self)
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

--------------------
-- CCMenuItemToggle
--------------------
CCMenuItemToggle = CCClass(CCMenuItem):include(CCRGBAProtocol)

ccProp{CCMenuItemToggle, "selectedIndex", mode="r"}

local kCCCurrentItemTag = "1234"

function CCMenuItemToggle:init(...)
    CCMenuItem.init(self)
    CCRGBAProtocol.init(self)
    self.subitems_ = arg
    self:setSelectedIndex(1)
end

function CCMenuItemToggle:cleanup()
    arrayRemoveAllObjects(self.subitems_)
    CCMenuItem.cleanup(self)
end

function CCMenuItemToggle:setSelectedIndex(index)
    if index ~= self.selectedIndex_ then
        self.selectedIndex_ = index
        
        local cur = self:getChildByTag(kCCCurrentItemTag)
        if cur then cur:removeFromParent(false) end
        
        local item = self.subitems_[index]
        self:addChild(item, 0, kCCCurrentItemTag)
        
        local s = item:contentSize()
        self:setContentSize(s)
        item:setPosition(s/2)
    end
end

function CCMenuItemToggle:selectedItem()
    return self.subitems_[self.selectedIndex_]
end

function CCMenuItemToggle:selected()
    CCMenuItem.selected(self)
    local item = self.subitems_[self.selectedIndex_]
    item:selected()
end

function CCMenuItemToggle:unselected()
    CCMenuItem.unselected(self)
    local item = self.subitems_[self.selectedIndex_]
    item:unselected()
end

function CCMenuItemToggle:activate()
    if self.isEnabled_ then
        local newIndex = self.selectedIndex_ + 1
        if newIndex > #self.subitems_ then newIndex = 1 end
        self:setSelectedIndex(newIndex)
    end
    
    CCMenuItem.activate(self)
end

function CCMenuItemToggle:setEnabled(enabled)
    if self.isEnabled_ ~= enabled then
        CCMenuItem.setEnabled(self, enabled)
        
        for i,item in ipairs(self.subitems_) do
            item:setEnabled(enabled)
        end
    end
end

function CCMenuItemToggle:setOpacity(o)
    CCRGBAProtocol.setOpacity(self, o)
    
    for i,v in ipairs(self.subitems_) do
        item:setOpacity(o)
    end
end

function CCMenuItemToggle:setColor(...)
    CCRGBAProtocol.setColor(self, ...)

    for i,v in ipairs(self.subitems_) do
        item:setColor(...)
    end        
end

function CCMenuItemToggle:setColor4(...)
    CCRGBAProtocol.setColor4(self, ...)

    for i,v in ipairs(self.subitems_) do
        item:setColor4(...)
    end        
end