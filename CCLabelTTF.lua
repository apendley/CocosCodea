--CCLabelTTF
CCLabelTTF = CCClass(CCNode):include(CCRGBAMixin):include(CCLabelMixin)

CCLabelTTF:synth{"fontName", ivar="font_", mode="r"}
CCLabelTTF:synth{"fontSize", mode="r"}
CCLabelTTF:synth{"alignment", mode="r"}
CCLabelTTF:synth{"wrapWidth", mode="r"}
CCLabelTTF:synth{"hasShadow"}
CCLabelTTF:synth{vec2, "shadowOffset", mode="rc"}
CCLabelTTF:synth{ccc4, "shadowColor", mode="rc"}
CCLabelTTF:synth{"shadowOpacity"}

function CCLabelTTF:init(str, fnt, fntSize, alignment, wrapWidth)
    CCNode.init(self)
    CCRGBAMixin.init(self)
    
    self.font_ = fnt or "Georgia"
    self.fontSize_ = fntSize or 17
    self.alignment_ = alignment_ or LEFT
    self.wrapWidth_ = wrapWidth_ or 0
    self.hasShadow_ = false
    self.anchor_ = vec2(0.5, 0.5)
        
    CCLabelMixin.init(self, str)
end

function CCLabelTTF:setHasShadow(hasShadow)
    self.hasShadow_ = hasShadow
    
    if hasShadow then
        self.shadowColor_ = self.shadowColor_ or ccc3(0, 0, 0)
        self.shadowOpacity_ = self.shadowOpacity_ or 255
        self.shadowOffset_ = self.shadowOffset_ or vec2(1, -1)
    end
end

function CCLabelTTF:setString(str)
    CCLabelMixin.setString(self, str)
    self:updateSize_()
end

function CCLabelTTF:setFontName(fontName)
    if self.font_ ~= fontName then
        self.font_ = fontName
        self:updateSize_()
    end
end

function CCLabelTTF:setFontSize(size)
    if self.fontSize_ ~= size then
        self.fontSize_ = size
        self:updateSize_()
    end
end

function CCLabelTTF:setAlignment(align)
    if self.alignment_ ~= align then
        self.alignment_ = align
        self:updateSize_()
    end
end

function CCLabelTTF:setWrapWidth(width)
    if self.wrapWidth_ ~= width then
        self.wrapWidth_ = width
        self:updateSize_()
    end
end

function CCLabelTTF:applyStyle()
    font(self.font_)
    fontSize(self.fontSize_)
    textAlign(self.alignment_)
    textWrapWidth(self.wrapWidth_)    
end

function CCLabelTTF:updateSize_()
    pushStyle()
    self:applyStyle()
    self:setSize(textSize(self:string()))
    popStyle()    
end

function CCLabelTTF:draw()
    self:applyStyle()
    textMode(CORNER)        
    
    if self.hasShadow_ then
        fill(self:shadowColor():unpack())
        local x, y = self:shadowOffset():unpack()
        text(self:string(), x, y)
    end
    
    local r, g, b = self.color_:unpack()
    fill(r, g, b, self.opacity_)
    text(self:string(), 0, 0)
    
    -- debug draw sprite rect
    --[[ 
    noFill()
    strokeWidth(2)
    stroke(255,128,128)
    local s = self:size()
    rect(0, 0, s.x, s.y)
    --]]    
end