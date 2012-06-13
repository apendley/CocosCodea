MyLayer2 = CCClass(CCLayer)

function MyLayer2:init()
    CCLayer.init(self)
    
    local item4
    do    
        local function resetScene()
            local t = CCTransitionFade(0.75, MyLayer:scene(), 0, 0, 0)            
            CCSharedDirector():replaceScene(t)
        end
        
        local item = CCMenuItemFont("Go To Scene 1", "Georgia", 30, CENTER)
        item:setHandler(resetScene)
        item:setColor(64, 64, 255)
        local pos = self:contentSize()/2
        pos.y = pos.y + 200
        item:setPosition(pos)
        item4 = item        
    end
    
    local menu = CCMenu(item4)
    menu:setContentSize(self:contentSize())
    menu:setPosition(self:position())
    menu:setAnchorPoint(self:anchorPoint())
    self:addChild(menu)    
end