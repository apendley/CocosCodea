MyLayer2 = CCClass(CCLayer)

function MyLayer2:init()
    CCLayer.init(self)
    
    self.dropFreeList = {}
    self.nextDrop = 1
    
    local size = self:contentSize()
    
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
        local ell = CCNodeEllipse(200, ccc4(192, 192, 192, 192))
        ell:setPosition(size.x/2, size.y/2 - 100)
        ell:setStrokeEnabled(true)
        ell:setStrokeColor(255, 128, 128)
        ell:setStrokeWidth(5)
        self:addChild(ell, 0)
        
        -- hang onto this ellipse, we use it later
        self.ellipse_ = ell
        self:setTouchEnabled(true)        
    end
    
    -- make the menu to contain the buttons
    local menu = CCMenu(exitButton)
    menu:setPosition(self:position())
    self:addChild(menu, 1) 
    
    -- make it rain
    self:schedule("spawnDrop", .075)
end

function MyLayer2:cleanup()
    CCLayer.cleanup(self)
    self.ellipse_ = nil
end

function MyLayer2:spawnDrop(dt)
    local numDrops = math.random(1, 3)
            
    for i = 1, numDrops do
        local dropFreeList = self.dropFreeList
        local drop
        if #dropFreeList > 0 then            
            drop = ccArrayRemove(dropFreeList)
        else
            --if self.nextDrop >= 40 then break end
            drop = CCSprite("Small World:Raindrop Soft")
            drop:setTag(self.nextDrop)
            self.nextDrop = self.nextDrop + 1
        end
                
        self:addChild(drop, -1)

        drop:setScale(.75 + (math.random() * .25))
        
        local cs = drop:contentSize()
        local ws = CCSharedDirector():winSize()
        
        local x = math.random(-cs.x, ws.x + cs.x)
        local y = ws.y + cs.y
        drop:setPosition(x, y)

        local function recycleDrop(d)
            ccArrayInsert(dropFreeList, d)
            d:removeFromParent(false)            
        end

        local d = 1 + math.random() * 1.5
        drop:runActions{CCMoveTo(d, x, -cs.y), CCFuncT(recycleDrop)}
    end
end

function MyLayer2:ccTouched(touch)
    local ell = self.ellipse_
    
    if touch.state == BEGAN then
        local p = ccVec2(touch.x, touch.y)
        p = CCSharedDirector():convertToGL(p)
        
        if ell:boundingBox():containsPoint(p) then
            self:reorderChild(ell, 25)
            ell:setStrokeColor(255, 255, 255)
            return true
        end
    elseif touch.state == MOVING then
        ell:setPosition(ell:position() + ccVec2(touch.deltaX, touch.deltaY))
    else
        ell:setStrokeColor(255, 128, 128)
        self:reorderChild(ell, -1)
    end
end
