CCSpriteFrameCache = CCClass()

-- Currently there is no support for batch loading sprite frames via
-- a plist file (as cocos2d-iphone supports). Once I write the parser,
-- this will be supported. Until then, it is only possible to cache
-- individual sprite frames.



-- singleton
local spci_ = nil
function CCSharedSpriteFrameCache()
    if not spci_ then spci_ = CCSpriteFrameCache() end
    return spci_
end

function CCSpriteFrameCache:init()
    -- apendley: can't decide if these tables should have weak keys or not.
    -- cocos2d-iphone supports removing unused frames, however since Lua
    -- is garbage collected and not ref-counted, we really don't have any
    -- way of knowing whether a frame is in use or not. A weak-keyed table
    -- would remove any frames not in use, but we can't control when they
    -- will be collected, hency my uncertainty. For now, sprite frames will
    -- retain in memory until they are explicitly removed
    self.spriteFrames_ = {}
    --self.spriteFrameAliases_ = {}
end

-- args: frameDict is optional; if specified, it should be either
-- a string-ified plist, or a table generated from plistParse().
-- If not specified, all frames are removed from the cache
function CCSpriteFrameCache:removeSpriteFrames(plist)
    if plist then
        if type(plist) == "string" then
            plist = plistParse(plist)
        end
        
        local pframes = plist.frames
        local frames = self.spriteFrames_
        
        for k,v in pairs(pframes) do
            frameName = string.sub(k, 1, -5)
            frames[frameName] = nil
        end
        
        -- todo: remove aliases if they exist?
    else
        local frames = self.spriteFrames_
        for k,v in pairs(frames) do
            frames[k] = nil
        end
        
        frames = self.spriteFrameAliases_
        for k,v in pairs(frames) do
            frames[k] = nil
        end
    end
end

-- args:
-- spritePack is the sprite pack where the texture referenced
-- by tableOrPlistString resides. tableOrPlistString is a table generated
-- from plistParse, or a string-ified plist. If using an old version
-- of the output from TexturePacker/Zwoptex (format == 0), then
-- spritePack must be the fully qualified texture name (i.e. "Documents:TextureName")
function CCSpriteFrameCache:addFrames(spritePack, tableOrPlistString)
    ccAssert(spritePack)
    
    local dict
    if type(tableOrPlistString) == "table" then
        dict = tableOrPlistString
    else
        dict = plistParse(tableOrPlistString)
    end
    
    local metadata, frames = dict.metadata, dict.frames
    
    -- plist must contain frames
    ccAssert(frames)

    local format, texture = 0
    if metadata then
        texture = metadata.textureFileName
        texture = spritePack..":"..string.sub(metadata.textureFileName, 1, -5)
        format = metadata.format        
    else
        texture = spritePack
    end

    -- must have a texture
    ccAssert(texture)    
    
    -- make sure format is supported
    ccAssert(format >= 0 and format <= 3)
    
    local frameName, frame
    for k, frameT in pairs(frames) do
        -- note that the frame name does not have a sprite pack prefix,
        -- and has no extension (i.e. "someSprite.png" -> "someSprite")
        frameName = string.sub(k, 1, -5)
        
        if format == 0 then
            local x = frameT.x
            local y = frameT.y
            local w = frameT.width
            local h = frameT.height
            local ox = frameT.offsetX
            local oy = frameT.offsetY
            local ow = frameT.originalWidth or 0
            local oh = frameT.originalHeight or 0

            ow = math.abs(ow)
            oh = math.abs(oh)
            
            frame = CCSpriteFrame(texture, ccRect(x, y, w, h), false, vec2(ox, oy), vec2(ow, oh))
        elseif format == 1 or format == 2 then
            local r = ccRectFromStr(frameT.frame)
            local rotated = (format == 2) and frameT.rotated or false
            local offset = ccVec2FromStr(frameT.offset)
            local sourceSize = ccVec2FromStr(frameT.sourceSize)

            frame = CCSpriteFrame(texture, r, rotated, offset, sourceSize)
        elseif format == 3 then
            local size = ccVec2FromStr(frameT.spriteSize)
            local offset = ccVec2FromStr(frameT.spriteOffset)
            local sourceSize = ccVec2FromStr(frameT.spriteSourceSize)
            local textureRect = ccRectFromStr(frameT.textureRect)
            local rotated = frameT.textureRotated
                
            -- todo: create aliases
            
            local r = ccRect(textureRect.x, textureRect.y, size.x, size.y)
            frame = CCSpriteFrame(texture, r, rotated, offset, sourceSize)
        end
        
        self.spriteFrames_[frameName] = frame
    end
end

function CCSpriteFrameCache:addFrame(frame, name)
    self.spriteFrames_[name] = frame
end

function CCSpriteFrameCache:removeFrame(name)
    self.spriteFrames_[name] = nil
end

function CCSpriteFrameCache:removeFramesFromTexture(texture)
    local frames = self.spriteFrames_
    for k,v in pairs(frames) do
        if v.texture == texture then
            frames[k] = nil
        end
    end
end

function CCSpriteFrameCache:frameByName(name)
    local f = self.spriteFrames_[name]
    if f then return f end
    
    -- todo: try aliases
end