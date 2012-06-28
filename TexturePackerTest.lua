TexturePackerTest = CCClass(CCLayer)

function TexturePackerTest:init()
    CCLayer.init(self)
    
    -- forward completion handlers to self's own handlers
    local function gotPlist(data, status, headers)
        self:gotPlist(data, status, headers)
    end
    
    local function gotTexture(img, status, headers)
        self:gotTexture(img, status, headers)
    end
    
    -- download the plist and texture    
    http.request("https://dl.dropbox.com/u/8445683/ExplosionSprites.plist", gotPlist)
    http.request("https://dl.dropbox.com/u/8445683/ExplosionSprites.png", gotTexture)
   
    -- put up "Downloading..." message
    local label = CCLabelTTF("Downloading...", "Georgia", 24, CENTER)
    label:setPosition(self:size()/2)
    self:addChild(label, 0, "label")
end

function TexturePackerTest:gotPlist(data, status, headers)
    self.dlPlist = plistParse(data)
    
    if self.dlTexture then self:downloadComplete() end
end

function TexturePackerTest:gotTexture(img, status, headers)
    local texName = "Documents:ExplosionSprites"
    
    -- apendley: work around Codea bug where @2x versions are not saved out
    -- on retina devices unless setContext() is used to create the image    
    ---[[
    local w, h = spriteSize(img)
    local newImg = image(w,h)
    setContext(newImg)
    sprite(img, w/2, h/2)
    setContext()
    img = newImg
    --]]
    
    saveImage(texName, img)    

    self.dlTexture = texName
    
    if self.dlPlist then self:downloadComplete() end
end

function TexturePackerTest:downloadComplete()
    -- remove the "Downloading..." label
    local label = self:getChildByTag("label")
    label:removeFromParent(true)
    
    -- add the frames from our sprite sheet frame list
    CCSharedSpriteFrameCache():addFrames("Documents", self.dlPlist)
    
    -- create a batch node
    local bn = CCSpriteBatchNode(self.dlTexture)
    bn:setPosition(self:position())
    bn:setAnchor(self:anchor())
    bn:setSize(self:size())
    bn:setIgnoreAnchorForPosition(self:ignoreAnchorForPosition())
    self:addChild(bn, 0, "batch")
    
    -- create a sprite using one of the frames from the sprite sheet
    local sp = CCSprite:alloc():initWithFrame("fxExplode00")
    sp:setPosition(self:size()/2)
    bn:addChild(sp, 0, "exp")
    
    -- animate the sprite using the frames from the sprite sheet
    self.curFrame = 0
    self.numFrames = 8    
    self:schedule("updateFrame", 1/10)
end

function TexturePackerTest:updateFrame(dt)
    self.curFrame = self.curFrame + 1
    
    if self.curFrame >= self.numFrames then
        self:unschedule("updateFrame")
        self:removeAllChildren(true)
    else
        local frame = string.format("fxExplode%.02d", self.curFrame)
        local sp = self:getChildByTag("batch"):getChildByTag("exp")
        sp:setDisplayFrame(frame)
    end
end