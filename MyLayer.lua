--MyLayer
MyLayer = CCClass(CCLayer)

function MyLayer:init()
    CCLayer.init(self)
    
    -- a label somewhere    
    do
        local label = CCLabelTTF("Some Random Label!", "AmericanTypewriter", 20, CENTER)
        label:setPosition(100, 100)
        self:addChild(label)        
    end
    
    local item1
    do
        local normal = CCSprite("Playing Cards:7_S")
        local selected = CCSprite("Playing Cards:7_S")
        selected:setColor(255, 128, 128)
        local item = CCMenuItemSprite(normal, selected)
        item:setHandler(ccDelegate(self, "itemSelected"))
        local pos = self:contentSize()/2
        pos.x = pos.x - 100
        item:setPosition(pos)
        item.tag = 1
        item.userData = "Left Button"
        item1 = item
    end
    
    local item2
    do
        local normal = CCNodeRect(200, 200, color(255, 255, 255))
        local selected = CCNodeRect(200, 200, color(0, 255, 0))
        local item = CCMenuItemSprite(normal, selected)
        item:setHandler(ccDelegate(self, "itemSelected"))
        local pos = self:contentSize()/2
        pos.x = pos.x + 100
        item:setPosition(pos)
        item.tag = 2
        item.userData = "Right Button"
        local label = CCLabelTTF("Hello!", "Helvetica", 30)
        label:setPosition(item:contentSize()/2)
        label:setColor(0, 0, 0)
        label:setAnchorPoint(.5, .5)
        item:addChild(label) 
        item2 = item
    end
    
    -- label item
    local item3
    do
        local item = CCMenuItemLabel(CCLabelTTF("A Label Button", "Georgia", 30, CENTER))
        local pos = self:contentSize()/2
        pos.y = pos.y - 200
        item:setPosition(pos)
        item3 = item
    end
    
    local item4
    do
        local changeFont = function(item_)
            item_:setFontName("Helvetica")
            item_:setFontSize(40)
            item_:setColor(128, 255, 128)
        end
    
        local item = CCMenuItemFont("Another Button", "Georgia", 30, CENTER)
        item:setHandler(changeFont)
        item:setColor(64, 64, 255)
        local pos = self:contentSize() / 2
        pos.y = pos.y + 200
        item:setPosition(pos)
        item4 = item        
    
        local seq = CCSequence:actions(CCDelayTime(3), CCCallT(changeFont))
        item:runAction(seq)
    end
    
    local menu = CCMenu(item1, item2, item3, item4)
    menu:setContentSize(self:contentSize())
    menu:setPosition(self:position())
    menu:setAnchorPoint(self:anchorPoint())
    self:addChild(menu)    

end

function MyLayer:itemSelected(item)
    print(item.userData .. " selected!")
end