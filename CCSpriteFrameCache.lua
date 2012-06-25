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
    -- retain in memory until they are explicitly purged
    self.spriteFrames_ = {}
    --self.spriteFrameAliases_ = {}
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
    return self.spriteFrames_[name]
end