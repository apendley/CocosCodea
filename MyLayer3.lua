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
        s:runActions{CCFadeOut(2), CCFadeIn(2), loop=true}
        self:addChild(s)
    end
      
    -- rotating sprite
    do
        local s = CCSprite("Planet Cute:Character Cat Girl")
        s:setPosition(size.x/2 - 250, size.y - 200)
        s:runActions{CCRotateBy(2, 180), loop=true}
        self:addChild(s)
    end
    
    -- pulsing sprite (scale)
    do
        local s = CCSprite("Planet Cute:Character Horn Girl")
        s:setPosition(size.x/2 - 250, size.y - 300)
        s:runActions{CCScaleBy(.2, 1.1), CCScaleBy(.2, 1/1.1), loop = true}
        self:addChild(s)        
    end
    
    -- color a sprite (tint)
    do
        local s = CCSprite("Planet Cute:Character Pink Girl")
        s:setPosition(size.x/2 - 250, size.y - 400)
        s:runActions{CCTintTo(1, 255, 0, 0), CCTintTo(1, 255), loop = true}
        self:addChild(s)        
    end
    
    -- move a sprite
    do
        local s = CCSprite("Planet Cute:Character Princess Girl")
        s:setPosition(size.x/2 - 250, size.y - 500)                
        
        s:runActions{ loop = true,
            CCMoveBy(3, 200, 0), 
            CCDelayTime(1),
            CCMoveBy(3, -200, 0),
            CCDelayTime(1),
        }        
        
        self:addChild(s)
    end
    
    -- move a sprite with ease in/out
    do
        local s = CCSprite("Planet Cute:Character Princess Girl")
        s:setPosition(size.x/2 - 250, size.y - 600)                
        
        s:runActions{ loop = true,
            CCEaseSineInOut(CCMoveBy(3, 200, 0)), 
            CCDelayTime(1),
            CCEaseSineInOut(CCMoveBy(3, -200, 0)),
            CCDelayTime(1),
        }
        
        self:addChild(s)
    end  
    
    -- change anchor point + simultaneous actions
    do
        local s = CCSprite("Planet Cute:Character Cat Girl")
        s:setAnchorPoint(0.5, 0)
        s:setPosition(size.x/2 + 250, size.y/2 - 200)
        s:runActions{CCRotateBy(2, 180), loop=true}
        s:runActions{CCScaleBy(.2, 1.1), CCScaleBy(.2, 1/1.1), loop=true}
        self:addChild(s)
    end
    
    -- hierarchy
    do
        local mine = CCSprite("Tyrian Remastered:Mine Spiked Huge")
        mine:setPosition(size.x/2 + 250, size.y/2 + 100)
        self:addChild(mine)
        
        mine:runActions{CCRotateBy(3, 360), loop=true}
        
        local ofs = 100        
        local xOfs = {-ofs, ofs, 0, 0}
        local yOfs = {0, 0, -ofs, ofs}

        local pos = mine:contentSize()/2          
        local rot = ccActions{CCRotateBy(1.5, -360), loop=true}
    
        for i = 1, 4 do
            orb = CCSprite("Tyrian Remastered:Orb 1")
            orb:setPosition(pos + vec2(xOfs[i], yOfs[i]))
            mine:addChild(orb)
            orb:runAction((i == 1) and rot or rot:copy())
        end
    end 
end