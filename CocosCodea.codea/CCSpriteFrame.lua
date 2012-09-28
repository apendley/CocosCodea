CCSpriteFrame = CCClass()

CCSpriteFrame:synth{"texture"}
CCSpriteFrame:synth{"rotated"}
CCSpriteFrame:synth{"rect", ccRect, mode = "#"}
CCSpriteFrame:synth{"offset", vec2, mode = "#"}

-- currently, Codea doesn't allow specifying texture coordinates
-- for sprites rendered using the sprite() command. Until then,
-- CCSpriteFrames can only be used with sprites rendered using
-- a CCSpriteBatchNode.
-- params: texture and rect_ are required, the rest are optional
function CCSpriteFrame:init(texture, rect_, rotated, offset, originalSize)
    ccAssert(texture and rect_)
    self.texture_ = texture
    self.rect_ = rect_
    self.rotated_ = rotated or false
    self.offset_ = offset or vec2(0, 0)
    self.originalSize_ = originalSize or rect_:size():copy()
end

function CCSpriteFrame:copy()
    return CCSpriteFrame(self.texture_, self.rect_, self.rotated_,
                         self.offset_, self.originalSize_)
end

function CCSpriteFrame:setRect(...)
    self.rect_ = ccRect(...)
end

function CCSpriteFrame:setOffset(...)
    self.offset_ = ccVec2VA(...)
end

