MyLayer3 = CCClass(CCLayer)

function MyLayer3:init()
    CCLayer.init(self)
    
    local size = self:contentSize()
    
    -- make a button to exit scene    
    local exitButton
    do    
        local function nextScene()
            local t = CCTransitionFade(0.75, MyRetinaTest:scene(), 255)
            CCSharedDirector():replaceScene(t)
        end
        
        local menu = CCMenu()
        menu:setPosition(self:position())
        self:addChild(menu)
        
        local item = CCMenuItemFont("Next Scene", "Georgia", 30, CENTER)
        item:setHandler(nextScene)
        item:setColor(64, 64, 255)
        item:setPosition(size.x/2, size.y/2 + 200)
        menu:addChild(item)
    end    
    
    -- sprite fade in/fade out
    do
        local s = CCSprite("Planet Cute:Character Boy")
        s:setPosition(size.x/2 - 250, size.y - 100)
        local seq = CCSequence{CCFadeOut(2), CCFadeIn(2)}
        s:runAction(CCLoop(seq))
        self:addChild(s)
    end
      
    -- rotating sprite
    do
        local s = CCSprite("Planet Cute:Character Cat Girl")
        s:setPosition(size.x/2 - 250, size.y - 200)
        s:runAction(CCLoop(CCRotateBy(2, 180)))
        self:addChild(s)
    end
    
    -- pulsing sprite (scale)
    do
        local s = CCSprite("Planet Cute:Character Horn Girl")
        s:setPosition(size.x/2 - 250, size.y - 300)
        local seq = CCSequence{CCScaleBy(.2, 1.1), CCScaleBy(.2, 1/1.1)}
        s:runAction(CCLoop(seq))
        self:addChild(s)        
    end
    
    -- color a sprite (tint)
    do
        local s = CCSprite("Planet Cute:Character Pink Girl")
        s:setPosition(size.x/2 - 250, size.y - 400)
        local seq = CCSequence{CCTintTo(1, 255, 0, 0), CCTintTo(1, 255)}
        s:runAction(CCLoop(seq))
        self:addChild(s)        
    end
    
    -- move a sprite
    do
        local s = CCSprite("Planet Cute:Character Princess Girl")
        s:setPosition(size.x/2 - 250, size.y - 500)                
        
        local seq = CCSequence
        {
            CCMoveBy(3, 200, 0), 
            CCDelayTime(1),
            CCMoveBy(3, -200, 0),
            CCDelayTime(1),
        }
        
        s:runAction(CCLoop(seq))
        self:addChild(s)
    end
    
    -- move a sprite with ease in/out
    do
        local s = CCSprite("Planet Cute:Character Princess Girl")
        s:setPosition(size.x/2 - 250, size.y - 600)                
        
        local seq = CCSequence
        {
            CCEaseSineInOut(CCMoveBy(3, 200, 0)), 
            CCDelayTime(1),
            CCEaseSineInOut(CCMoveBy(3, -200, 0)),
            CCDelayTime(1),
        }
        
        s:runAction(CCLoop(seq))
        self:addChild(s)
    end  
    
    -- change anchor point + simultaneous actions
    do
        local s = CCSprite("Planet Cute:Character Cat Girl")
        s:setAnchorPoint(0.5, 0)
        s:setPosition(size.x/2 + 250, size.y/2 - 200)
        
        s:runAction(CCLoop(CCRotateBy(2, 180)))
        local seq = CCSequence{CCScaleBy(.2, 1.1), CCScaleBy(.2, 1/1.1)}        
        s:runAction(CCLoop(seq))
        self:addChild(s)
    end     
    
    --sprite("Tyrian Remastered:Orb 1")        
    
    -- hierarchy
    do
        local mine = CCSprite("Tyrian Remastered:Mine Spiked Huge")
        mine:setPosition(size.x/2 + 250, size.y/2 + 100)
        local pos = mine:contentSize()/2
        local ofs = 100
        self:addChild(mine)
        
        local rot = CCRotateBy(3, 360)        
        mine:runAction(CCLoop(rot))        
        
        local orbSprite = "Tyrian Remastered:Orb 1"        
        local orb = CCSprite(orbSprite)
        orb:setPosition(pos.x - ofs, pos.y)
        mine:addChild(orb)
        local rot2 = CCRotateBy(1.5, -360)
        orb:runAction(CCLoop(rot2))
        
        orb = CCSprite(orbSprite)
        orb:setPosition(pos.x + ofs, pos.y)
        mine:addChild(orb)
        orb:runAction(CCLoop(rot2:copy()))        
        
        orb = CCSprite(orbSprite)
        orb:setPosition(pos.x, pos.y - ofs)
        mine:addChild(orb)
        orb:runAction(CCLoop(rot2:copy()))                  
        
        orb = CCSprite(orbSprite)
        orb:setPosition(pos.x, pos.y + ofs)
        mine:addChild(orb)
        orb:runAction(CCLoop(rot2:copy()))                  
        
    end 
end