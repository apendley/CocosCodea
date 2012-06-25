CCSpriteFrame = CCClass()

-- currently, Codea doesn't allow specifying texture coordinates
-- for sprites rendered using the sprite() command. Until then,
-- CCSpriteFrames can only be used with sprites rendered using
-- a CCSpriteBatchNode
function CCSpriteFrame:init(texture, rect_)
    ccAssert(texture and rect_)
    self.texture = texture
    self.rect = rect_
    --self.rectInPixels = ???
    
    -- these will be added once support for TexturePacker/Zwoptex is added,
    -- which will happen when I write code to parse the plists they generate
    -- self.rotated = rotated
    -- self.offset = offset
    -- self.offsetInPixels = ???
    -- self.originalSize = ???
    -- self.originalSizeInPixels = ???
end