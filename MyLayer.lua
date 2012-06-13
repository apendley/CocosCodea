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
    
    --[[
    local item2
    do
        local normal = CCNodeRect(200, 200, ccColor(255, 255, 255))
        local selected = CCNodeRect(200, 200, ccColor(0, 255, 0))
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
    --]]
    
    local item2
    do
        local label = CCLabelTTF("Hello!", "Helvetica", 30)
        local normal = CCNodeRect(200, 200, ccColor(255, 0, 0))
        local selected = CCNodeRect(200, 200, ccColor(0, 255, 0))
        local item = CCMenuItemBackedLabel(label, normal, selected)
        item:setHandler(ccDelegate(self, "itemSelected"))        
        local pos = self:contentSize()/2
        pos.x = pos.x + 100
        item:setPosition(pos)
        item.tag = 2
        item.userData = "Right Button"
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
        local function resetScene()
            local t = CCTransitionFade(0.75, MyLayer2:scene(), 0, 0, 0)
            CCSharedDirector():replaceScene(t)
        end
        
        local item = CCMenuItemFont("Go To Scene 2", "Georgia", 30, CENTER)
        item:setHandler(resetScene)
        item:setColor(64, 64, 255)
        local pos = self:contentSize() / 2
        pos.y = pos.y + 200
        item:setPosition(pos)
        item4 = item        
    
        local changeFont = function(item_)
            item_:setFontName("Helvetica")
            item_:setFontSize(40)
            item_:setColor(128, 255, 128)
        end    
    
        local seq = CCSequence:actions(CCDelayTime(3), CCCallT(changeFont))
        item:runAction(seq)
    end
    
    local item5
    do
        local function onSelected(i)
            ccPrint(i:selectedItem().userdata)
        end
        
        local i1s1 = CCSprite("Playing Cards:cardback2")
        local i1s2 = CCSprite("Playing Cards:cardback2")
        i1s2:setColor(255, 128, 128)
        local item1 = CCMenuItemSprite(i1s1, i1s2)
        item1.userdata = "Back"
        
        local i2s1 = CCSprite("Playing Cards:A_S")
        local i2s2 = CCSprite("Playing Cards:A_S")
        i2s2:setColor(255, 128, 128)        
        local item2 = CCMenuItemSprite(i2s1, i2s2)
        item2.userdata = "Front"
                
        local toggle = CCMenuItemToggle(item1, item2)
        toggle:setHandler(onSelected)
        local pos = self:contentSize()/2
        pos.x = toggle:contentSize().x/2 + 20
        toggle:setPosition(pos)
        item5 = toggle
    end
    
    local menu = CCMenu(item1, item2, item3, item4, item5)
    menu:setContentSize(self:contentSize())
    menu:setPosition(self:position())
    menu:setAnchorPoint(self:anchorPoint())
    self:addChild(menu)    

end

function MyLayer:itemSelected(item)
    ccPrint(item.userData .. " selected!")
end