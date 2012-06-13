--MyLayer
MyLayer = CCClass(CCLayer)

function MyLayer:init()
    CCLayer.init(self)
    
    -- a label somewhere    
    do
        local label = CCLabelTTF("", "AmericanTypewriter", 40, CENTER)
        local size = self:contentSize()
        label:setAnchorPoint(0.5, 1)
        label:setPosition(size.x/2, size.y)
        label:setHasShadow(true)
        self:addChild(label)        
        self.statusLabel = label
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
        item.userData = "Seven of Spades"
        item1 = item
        
        local duration = .2
        local function randomAnchorPoint(target)
            local range = 2
            local x = math.random(50-range/2, 50+range/2) / 100
            local y = math.random(50-range/2, 50+range/2) / 100
            local ap = target:anchorPoint()
            local tween = CCTween(duration, "setAnchorPoint", ap, vec2(x,y))
            target:runAction(tween)
        end
        
        local sequence =
        {
            CCDelayTime(duration), CCCallT(randomAnchorPoint),
        }
        
        
        item:runAction(CCRepeatForever(CCSequence(sequence)))
        
        sequence =
        {
            CCEaseSineInOut(CCRotateTo(.10, -1.5)),
            CCEaseSineInOut(CCRotateBy(.10, 3))
        }
        
        local loop = CCRepeatForever(CCSequence(sequence))
        item:runAction(loop)
    end
    
    local item2
    do
        local label = CCLabelTTF("Hello!", "Helvetica", 30)
        local normal = CCNodeRect(200, 200, 255, 0, 0)
        local selected = CCNodeRect(200, 200, ccc3(0, 255, 0))
        normal:setStrokeEnabled(true)
        normal:setStrokeColor(255)
        selected:setStrokeEnabled(true)
        selected:setStrokeColor(0)
        local item = CCMenuItemBackedLabel(label, normal, selected)
        item:setHandler(ccDelegate(self, "itemSelected"))        
        local pos = self:contentSize()/2
        pos.x = pos.x + 100
        item:setPosition(pos)
        item.tag = 2
        item.userData = "Right Button"
        item:label():setHasShadow(true)
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
        
        local seq = CCSequence(CCTintTo(0.5, 0), CCTintTo(.5, 255, 0, 255))
        item:runAction(CCRepeatForever(CCEaseSineInOut(seq)))
    end
    
    local item4
    do    
        local function nextScene()
            local t = CCTransitionShrinkGrow(2, MyLayer2:scene())
            CCSharedDirector():replaceScene(t)
        end
        
        local item = CCMenuItemFont("Go To Scene 2", "Georgia", 30, CENTER)
        item:setHandler(nextScene)
        item:setColor(255, 255, 255)
        local pos = self:contentSize() / 2
        pos.y = pos.y + 200
        item:setPosition(pos)
        item4 = item
        
        item:label():setHasShadow(true)
        item:label():setShadowColor(128, 128, 255, 160)
    
        local cs = item:contentSize()
        local bg = CCNodeRect(cs.x*1.5, cs.y*1.5, 0, 0, 0)
        bg:setPosition(item:position())
        bg:setAnchorPoint(item:anchorPoint())
        self:addChild(bg, -1)
                
        local seq = CCSequence(CCScaleBy(0.3, 1.1), CCScaleBy(0.3, 1/1.1))
        bg:runAction(CCRepeatForever(CCEaseSineInOut(seq)))
    end
    
    local item5
    do
        local function onSelected(i)
            self.statusLabel:setString(i:selectedItem().userData)
        end
        
        local i1s1 = CCSprite("Playing Cards:cardback2")
        local i1s2 = CCSprite("Playing Cards:cardback2")
        i1s2:setColor(255, 128, 128)
        local item1 = CCMenuItemSprite(i1s1, i1s2)
        item1.userData = "Back"
        
        local i2s1 = CCSprite("Playing Cards:A_S")
        local i2s2 = CCSprite("Playing Cards:A_S")
        i2s2:setColor(255, 128, 128)        
        local item2 = CCMenuItemSprite(i2s1, i2s2)
        item2.userData = "Front"
                
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
    self.statusLabel:setString(item.userData or "")
end

function MyLayer:cleanup()
    CCLayer.cleanup(self)
    self.statusLabel = nil
end