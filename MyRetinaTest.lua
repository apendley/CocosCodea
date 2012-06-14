MyRetinaTest = CCClass(CCLayer)

local function createSprite(name, ofsx, ofsy)
    local sprite = CCSprite(name)
    local pos = CCSharedDirector():winSize()/2
    pos.x, pos.y = pos.x + ofsx, pos.y + ofsy
    sprite:setPosition(pos)    
    return sprite
end

local function createImage(name, ofsx, ofsy)
    local img = readImage(name)
    local sprite = CCSprite(img)
    local pos = CCSharedDirector():winSize()/2
    pos.x, pos.y = pos.x + ofsx, pos.y + ofsy
    sprite:setPosition(pos)    
    return sprite
end

    -- non-retina images
    local nonretina = 
    {
        {"Tyrian Remastered:Boss A", -50, -150 },
        {"Tyrian Remastered:Blimp Boss", -50, 0 },
        {"SpaceCute:Beetle Ship", -50, 180 },
        {"Planet Cute:Chest Closed", -250, 0 },
    }
    
    -- retina images
    local retina =
    {
        {"Small World:Church", 180, 0},
    }

function MyRetinaTest:init()
    CCLayer.init(self)
    
    sprite("Small World:Church")
    
    -- keep these on a different layer
    local layer = CCLayer()
    layer:setPosition(self:position())
    self:addChild(layer)
    self.layer = layer
    
    --local create = createImage
    self:populate(createSprite)
    
    local m = CCMenu(toggle)
    m:setPosition(self:position())
    self:addChild(m)    
    
    do
        local enable = CCMenuItemFont("Double Size Mode Enabled", "Georgia", 30)
        enable.userData = "disable"
        local disable = CCMenuItemFont("Double Size Mode Disabled", "Georgia", 30)
        disable.userData = "enable"
        local toggle = CCMenuItemToggle(enable, disable)
        toggle:setHandler(self, "toggled")
        local size = self:contentSize()
        local pos = vec2(size.x/2, 80)
        toggle:setPosition(pos)
        m:addChild(toggle)
    end
    do
        local enable = CCMenuItemFont("Use image objects", "Georgia", 30)
        enable.userData = "image"
        local disable = CCMenuItemFont("Use sprites", "Georgia", 30)
        disable.userData = "sprite"
        local toggle = CCMenuItemToggle(enable, disable)
        toggle:setHandler(self, "imageToggled")
        local size = self:contentSize()
        local pos = vec2(size.x/2, 30)
        toggle:setPosition(pos)
        m:addChild(toggle)
    end    
    
end

function MyRetinaTest:populate(create)
    local layer = self.layer
    
    for i,v in ipairs(nonretina) do
        layer:addChild(create(unpack(v)))
    end
    
    for i,v in ipairs(retina) do
        layer:addChild(create(unpack(v)))
    end
end

function MyRetinaTest:toggled(toggle)
    local item = toggle:selectedItem()
    
    if item.userData == "enable" then
        CC_ENABLE_CODEA_RETINA_SUPPORT = true
    else
        CC_ENABLE_CODEA_RETINA_SUPPORT = false        
    end
end

function MyRetinaTest:imageToggled(toggle)
    local item = toggle:selectedItem()
    
    local layer = self.layer
    layer:removeAllChildren(true)
        
    if item.userData == "image" then
        self:populate(createImage)
    else
        self:populate(createSprite)
    end
end