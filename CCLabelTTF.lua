--CCLabelTTF
CCLabelTTF = CCClass(CCNode):include(CCRGBAMixin):include(CCLabelMixin)

ccProp{CCLabelTTF, "fontName", "font_", mode="r"}
ccProp{CCLabelTTF, "fontSize", mode="r"}
ccProp{CCLabelTTF, "alignment", mode="r"}
ccProp{CCLabelTTF, "wrapWidth", mode="r"}
ccProp{CCLabelTTF, "hasShadow"}
ccPropVec2{CCLabelTTF, "shadowOffset"}
ccPropColor4{CCLabelTTF, "shadowColor"}

function CCLabelTTF:init(str, fnt, fntSize, alignment, wrapWidth)
    CCNode.init(self)
    CCRGBAMixin.init(self)
    
    self.font_ = fnt or "Georgia"
    self.fontSize_ = fntSize or 17
    self.alignment_ = alignment_ or LEFT
    self.wrapWidth_ = wrapWidth_ or 0
    self.hasShadow_ = false
    self.shadowOffset_ = vec2(2,-2)
        
    CCLabelMixin.init(self, str)
end

function CCLabelTTF:setString(str)
    CCLabelMixin.setString(self, str)
    self:updateContentSize_()
end

function CCLabelTTF:setFontName(fontName)
    if self.font_ ~= fontName then
        self.font_ = fontName
        self:updateContentSize_()
    end
end

function CCLabelTTF:setFontSize(size)
    if self.fontSize_ ~= size then
        self.fontSize_ = size
        self:updateContentSize_()
    end
end

function CCLabelTTF:setAlignment(align)
    if self.alignment_ ~= align then
        self.alignment_ = align
        self:updateContentSize_()
    end
end

function CCLabelTTF:setWrapWidth(width)
    if self.wrapWidth_ ~= width then
        self.wrapWidth_ = width
        self:updateContentSize_()
    end
end

function CCLabelTTF:applyStyle()
    font(self.font_)
    fontSize(self.fontSize_)
    textAlign(self.alignment_)
    textWrapWidth(self.wrapWidth_)    
end

function CCLabelTTF:updateContentSize_()
    pushStyle()
    self:applyStyle()
    self:setContentSize(textSize(self:string()))
    popStyle()    
end

function CCLabelTTF:draw()
    self:applyStyle()
    textMode(CORNER)        
    
    if self.hasShadow_ then
        local ofs = self.shadowOffset_
        local col = self.shadowColor_ or ccc3(0,0,0)
        fill(col)
        text(self:string(), ofs.x, ofs.y)
    end
    
    fill(self:color())
    text(self:string(), 0, 0)
    
    -- debug draw sprite rect
    --[[ 
    noFill()
    strokeWidth(2)
    stroke(255,128,128)
    local s = self:contentSize()
    rect(0, 0, s.x, s.y)
    --]]    
end