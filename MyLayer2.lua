MyLayer2 = CCClass(CCLayer)

function MyLayer2:init()
    CCLayer.init(self)
    
    local item4
    do    
        local function resetScene()
            local t = CCTransitionSlideInB(0.75, MyLayer:scene())
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
    
    do
        local ell = CCNodeEllipse(100, ccc4(128, 255, 255))
        local pos = self:contentSize()/2
        pos.y = pos.y - 200
        ell:setPosition(pos)
        ell:setAnchorPoint(.5, .5)
        self:addChild(ell)
    end
    
    local menu = CCMenu(item4)
    menu:setContentSize(self:contentSize())
    menu:setPosition(self:position())
    menu:setAnchorPoint(self:anchorPoint())
    self:addChild(menu)    
end

