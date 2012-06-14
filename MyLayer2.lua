MyLayer2 = CCClass(CCLayer)

function MyLayer2:init()
    CCLayer.init(self)
    
    -- make a button to exit scene    
    local exitButton
    do    
        local function resetScene()
            local t = CCTransitionFade(0.75, MyLayer:scene(), 0)
            CCSharedDirector():replaceScene(t)
        end
        
        local item = CCMenuItemFont("Go To Scene 1", "Georgia", 30, CENTER)
        item:setHandler(resetScene)
        item:setColor(64, 64, 255)
        
        local pos = self:contentSize()/2
        pos.y = pos.y + 200
        item:setPosition(pos)
        exitButton = item
    end
    
    -- make an ellipse that we can drag around
    do
        local ell = CCNodeEllipse(200, ccc4(192, 192, 192, 192))
        local pos = self:contentSize()/2
        pos.y = pos.y - 200
        ell:setPosition(pos)
        ell:setStrokeEnabled(true)
        ell:setStrokeColor(255, 128, 128)
        ell:setStrokeWidth(5)
        self:addChild(ell, -1)
        
        -- hang onto this ellipse, we use it later
        self.ellipse_ = ell
        self:setTouchEnabled(true)        
    end
    
    -- make the menu to contain the buttons
    local menu = CCMenu(exitButton)
    menu:setPosition(self:position())
    self:addChild(menu, 0) 
    
    -- make it rain
    self:schedule("spawnDrop", .1)
end

function MyLayer2:cleanup()
    CCLayer.cleanup(self)
    self.ellipse_ = nil
end

function MyLayer2:spawnDrop(dt)
    local numDrops = math.random(1, 3)
            
    for i = 1, numDrops do
        local drop = CCSprite("Small World:Raindrop Soft")
        local z = math.random(1, 20) - 10        
        self:addChild(drop, z)

        local s = 0.75 + ((z + 10) * .0125)
        drop:setScale(s)
        
        local cs = drop:contentSize()
        local ws = CCSharedDirector():winSize()
        
        local x = math.random(-cs.x, ws.x + cs.x)
        local y = ws.y + cs.y
        drop:setPosition(x, y)

        local d = 1 + math.random() * 1.5
        local fall = CCMoveTo(d, x, -cs.y)
        local remove = CCCallTarget("removeFromParent", true)
        drop:runAction(CCSequence(fall, remove))
    end
end

function MyLayer2:ccTouched(touch)
    local ell = self.ellipse_
    
    if touch.state == BEGAN then
        local p = vec2(touch.x, touch.y)
        p = CCSharedDirector():convertToGL(p)
        
        if ell:boundingBox():containsPoint(p) then
            self:reorderChild(ell, 25)
            ell:setStrokeColor(255, 255, 255)
            return true
        end
    elseif touch.state == MOVING then
        ell:setPosition(ell:position() + vec2(touch.deltaX, touch.deltaY))
    else
        ell:setStrokeColor(255, 128, 128)
        self:reorderChild(ell, -1)
    end
end
