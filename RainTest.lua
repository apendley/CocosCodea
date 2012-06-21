RainTest = CCClass(CCLayer)

function RainTest:init()
    CCLayer.init(self)
    
    self:setTouchEnabled(true)
    
    local size = self:size()
    
    local bn = CCSpriteBatchNode("Small World:Raindrop Soft")
    bn:setSize(size)
    bn:setAnchor(self:anchor())
    bn:setPosition(self:position())
    bn:setIgnoreAnchorForPosition(true)
    self:addChild(bn)
    self.batchNode = bn
    
    -- make a button to exit scene    
    local exitButton
    do    
        local function nextScene()
            local t = CCTransitionFade(0.75, MyLayer3:scene(), 0)
            CCSharedDirector():replaceScene(t)
        end
        
        local item = CCMenuItemFont("Next Scene", "Georgia", 30, CENTER)
        item:setHandler(nextScene)
        item:setColor(64, 64, 255)
        item:setPosition(size.x/2, size.y/2 + 200)
        exitButton = item
    end
    
    -- make an ellipse that we can drag around
    do
        local ell = CCNodeEllipse(200, ccc3(192, 192, 192))
        ell:setPosition(size.x/2, size.y/2 - 100)
        ell:setOpacity(192)
        ell:setStrokeEnabled(true)
        ell:setStrokeColor(255, 128, 128, 128)
        ell:setStrokeWidth(5)
        self:addChild(ell, 0)
        
        -- hang onto this ellipse, we use it later
        self.ellipse_ = ell
        self:setTouchEnabled(true)        
    end
    
    -- make the menu to contain the buttons
    local menu = CCMenu(exitButton)
    menu:setPosition(self:position())
    self:addChild(menu, 2) 
    
    -- make it rain
    self.drops = {}
    self.freeDrops = {}
    self:schedule("spawnDrops", 1/45)
    self:schedule("updateDrops")
end

function RainTest:spawnDrops(dt)
    local drop    
    for i = 1, math.random(1, 2) do
        if #self.freeDrops > 0 then
            drop = table.remove(self.freeDrops)
            drop:setVisible(true)            
        else
            drop = CCSprite("Small World:Raindrop Soft")
            self.batchNode:addChild(drop)
            --self:addChild(drop)
        end
        
        drop:setScale(.75 + (math.random() * .25))
        
        local cs = drop:size()
        local w, h = self:size():unpack()
        local x = math.random(-cs.x, w + cs.x)
        local y = h + cs.y * .5 + math.random(50)
        drop:setPosition(x, y)
        
        -- yeah, we can cheat here because we're using Lua :)
        drop.rate_ = math.random(600, 1200)
        table.insert(self.drops, drop)
    end
end

function RainTest:updateDrops(dt)
    local remove = {}
    for i, drop in ipairs(self.drops) do
        local x, y = drop:position():unpack()
        
        if y < -40 then
            drop:setVisible(false)
            table.insert(remove, drop)
            table.insert(self.freeDrops, drop)
        else
            y = y - drop.rate_ * dt
            drop:setPosition(x, y)            
        end
    end
    
    for i, drop in ipairs(remove) do
        ccArrayRemoveObject(self.drops, drop)
    end
end

function RainTest:ccTouched(touch)
    local ell = self.ellipse_
    
    if touch.state == BEGAN then
        local p = ccVec2(touch.x, touch.y)
        p = CCSharedDirector():convertToGL(p)
        
        if ell:boundingBox():containsPoint(p) then
            self:reorderChild(ell, 3)
            ell:setStrokeColor(255, 255, 255)
            return true
        end
    elseif touch.state == MOVING then
        ell:setPosition(ell:position() + ccVec2(touch.deltaX, touch.deltaY))
    else
        ell:setStrokeColor(255, 128, 128, 128)
        self:reorderChild(ell, 0)
    end
end

function RainTest:cleanup()
    CCLayer.cleanup(self)
    self.ellipse_ = nil
    self.drops = nil
    self.freeDrops = nil
end
