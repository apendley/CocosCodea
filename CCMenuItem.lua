--CCMenuItem
CCMenuItem = CCClass(CCNode)

CCMenuItem:synth{"isEnabled", set="setEnabled"}
CCMenuItem:synth{"isSelected", mode="r"}

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

-- setHandler(function)
-- setHandler(target, selector)
function CCMenuItem:setHandler(...)
    if #arg == 1 then
        self.handler_ = arg[1]
    elseif #arg == 2 then
        self.handler_ = ccDelegate(arg[1], arg[2])
        --self.handler_ = function() end
    else
        ccAssert(false, "CCMenuItem:setHandler -> invalid parameters")
    end
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
CCMenuItemSprite = CCClass(CCMenuItem):include(CCMenuItemSpriteMixin)

function CCMenuItemSprite:init(normalSprite, selectedSprite, disabledSprite)
    CCMenuItem.init(self)
    CCMenuItemSpriteMixin.init(self, normalSprite, selectedSprite, disabledSprite)
end

function CCMenuItemSprite:cleanup()
    CCMenuItem.cleanup(self)
    CCMenuItemSpriteMixin.cleanup(self)
end

function CCMenuItemSprite:selected()
    CCMenuItem.selected(self)
    CCMenuItemSpriteMixin.selected(self)
end

function CCMenuItemSprite:unselected()
    CCMenuItem.unselected(self)
    CCMenuItemSpriteMixin.unselected(self)
end

function CCMenuItemSprite:setEnabled(enabled)
    if self.isEnabled_ ~= enabled then
        CCMenuItem.setEnabled(self, enabled)
        CCMenuItemSpriteMixin.setEnabled(self, enabled)
    end
end




--------------------
-- CCMenuItemLabel
--------------------
CCMenuItemLabel = CCClass(CCMenuItem):include(CCMenuItemLabelMixin)

function CCMenuItemLabel:init(label)
    CCMenuItem.init(self)
    CCMenuItemLabelMixin.init(self, label)
end

function CCMenuItemLabel:activate()
    if self.isEnabled_ then
        CCMenuItemLabelMixin.activate(self)
        CCMenuItem.activate(self)
    end
end

function CCMenuItemLabel:selected()
    if self.isEnabled_ then
        CCMenuItem.selected(self)
        CCMenuItemLabelMixin.selected(self)
    end
end

function CCMenuItemLabel:unselected()
    if self.isEnabled_ then
        CCMenuItem.unselected(self)
        CCMenuItemLabelMixin.unselected(self)
    end
end

function CCMenuItemLabel:setEnabled(enabled)
    CCMenuItemLabelMixin.setEnabled(self, enabled)
    CCMenuItem.setEnabled(self, enabled)
end

function CCMenuItemLabel:cleanup()
    CCMenuItem.cleanup(self)
    CCMenuItemLabelMixin.cleanup(self)
end

----------------------------------------
-- CCMenuItemBackedLabel
----------------------------------------
CCMenuItemBackedLabel = CCClass(CCMenuItem)
CCMenuItemBackedLabel:include(CCMenuItemSpriteMixin)
CCMenuItemBackedLabel:include(CCMenuItemLabelMixin)

function CCMenuItemBackedLabel:init(label, normal, selected, disabled)
    assert(label and normal)
    CCMenuItem.init(self)
    CCMenuItemSpriteMixin.init(self, normal, selected, disabled)    
    CCMenuItemLabelMixin.init(self, label)    
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
        CCMenuItemLabelMixin.activate(self)
        CCMenuItem.activate(self)
    end
end

function CCMenuItemBackedLabel:selected()
    if self.isEnabled_ then
        CCMenuItem.selected(self)
        CCMenuItemLabelMixin.selected(self)
        CCMenuItemSpriteMixin.selected(self)
    end
end

function CCMenuItemBackedLabel:unselected()
    if self.isEnabled_ then
        CCMenuItem.unselected(self)
        CCMenuItemLabelMixin.unselected(self)
        CCMenuItemSpriteMixin.unselected(self)    
    end
end

function CCMenuItemBackedLabel:setEnabled(enabled)
    CCMenuItemLabelMixin.setEnabled(self, enabled)
    CCMenuItemSpriteMixin.setEnabled(self, enabled)
    CCMenuItem.setEnabled(self, enabled)
end

function CCMenuItemBackedLabel:cleanup()
    CCMenuItem.cleanup(self)
    CCMenuItemLabelMixin.cleanup(self)
    CCMenuItemSpriteMixin.cleanup(self)
end

function CCMenuItemBackedLabel:setOpacity(o)
    CCMenuItemLabelMixin.setOpacity(self, o)
    CCMenuItemSpriteMixin.setOpacity(self, o)
end
    
function CCMenuItemBackedLabel:opacity()
    return CCMenuItemLabelMixin.opacity(self)
end

function CCMenuItemBackedLabel:setColor(...)
    CCMenuItemLabelMixin.setColor(self, ...)
    CCMenuItemSpriteMixin.setColor(self, ...)
end

function CCMenuItemBackedLabel:color()    
    return CCMenuItemLabelMixin.color(self)
end

function CCMenuItemBackedLabel:setColor4(...)
    CCMenuItemLabelMixin.setColor4(self, ...)
    CCMenuItemSpriteMixin.setColor4(self, ...)    
end

function CCMenuItemBackedLabel:color4()
    return CCMenuItemLabelMixin.color4(self)
end


--------------------
-- CCMenuItemFont
--------------------
CCMenuItemFont = CCClass(CCMenuItemLabel)

CCMenuItemFont:synth{"fontSize", mode="r"}
CCMenuItemFont:synth{"fontName", mode="r"}
CCMenuItemFont:synth{"alignment", mode="r"}
CCMenuItemFont:synth{"wrapWidth", mode="r"}

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
CCMenuItemToggle = CCClass(CCMenuItem):include(CCRGBAMixin)

function CCMenuItemToggle:init(...)
    CCMenuItem.init(self)
    CCRGBAMixin.init(self)
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
        self:addChild(item, 0)
        
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
    CCRGBAMixin.setOpacity(self, o)
    
    for i,v in ipairs(self.subitems_) do
        item:setOpacity(o)
    end
end

function CCMenuItemToggle:setColor(...)
    CCRGBAMixin.setColor(self, ...)

    for i,v in ipairs(self.subitems_) do
        item:setColor(...)
    end        
end

function CCMenuItemToggle:setColor4(...)
    CCRGBAMixin.setColor4(self, ...)

    for i,v in ipairs(self.subitems_) do
        item:setColor4(...)
    end        
end