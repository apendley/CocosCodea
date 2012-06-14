--MyLayer
MyLayer = CCClass(CCLayer)

function MyLayer:init()
    CCLayer.init(self)
    
    local size = self:contentSize()    
    
    -- status label
    do
        local label = CCLabelTTF("", "AmericanTypewriter", 40, CENTER)
        label:setAnchorPoint(0.5, 1)
        label:setPosition(size.x/2, size.y)
        label:setHasShadow(true)
        self:addChild(label)        
        self.statusLabel = label
    end
    
    -- menu to contain buttons
    local menu = CCMenu()
    menu:setPosition(self:position())
    self:addChild(menu)    
    
    -- a tree
    do
        local normal = CCSprite("Small World:Tree 2")
        local selected = CCSprite("Small World:Tree 2")
        selected:setColor(255, 128, 128)
        
        local item = CCMenuItemSprite(normal, selected)
        menu:addChild(item, 0, "A Tree!")
        item:setHandler(self, "itemSelected")
        item:setPosition(size.x/2 - 100, size.y/2)
        item:setScale(2)
        
        local duration = .2
        local function randomAnchorPoint(target)
            local range = 2
            local x = math.random(50-range/2, 50+range/2) / 100
            local y = math.random(50-range/2, 50+range/2) / 100
            local ap = target:anchorPoint()
            local tween = CCTween(duration, "setAnchorPoint", ap, ccVec2(x,y))
            target:runAction(tween)
        end
        
        local sequence =
        {
            CCDelayTime(duration), CCFuncT(randomAnchorPoint),
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
    
    -- Hello! button
    do
        local label = CCLabelTTF("Hello!", "Helvetica", 50)
        label:setHasShadow(true)
        
        local normal = CCNodeRect(200, 200, 255, 0, 0)
        normal:setStrokeEnabled(true)
        normal:setStrokeColor(255)
                
        local selected = CCNodeRect(200, 200, ccc3(0, 255, 0))
        selected:setStrokeEnabled(true)
        selected:setStrokeColor(0)
        
        local item = CCMenuItemBackedLabel(label, normal, selected)
        item:setHandler(self, "itemSelected")
        item:setPosition(size.x/2 + 100, size.y/2)        
        menu:addChild(item, 0, "Hello!")
    end
    
    -- a button to exit the scene
    do    
        local function nextScene()
            local t = CCTransitionRotoZoom(1, MyLayer2:scene())
            CCSharedDirector():replaceScene(t)
        end
        
        local item = CCMenuItemFont("Next Scene", "Georgia", 30, CENTER)
        item:setHandler(nextScene)
        item:setColor(255, 255, 255)        
        item:setPosition(size.x/2, size.y/2 + 200)
        menu:addChild(item)        
        
        local label = item:label()
        label:setHasShadow(true)
        label:setShadowColor(128, 128, 255, 160)
    
        local cs = item:contentSize()
        local bg = CCNodeRect(cs.x*1.5, cs.y*1.5, 0, 0, 128)
        self:addChild(bg, -1)        
        bg:setPosition(item:position())
        bg:setAnchorPoint(item:anchorPoint())
        bg:setStrokeEnabled(true)
        bg:setStrokeColor(255)
        bg:setStrokeWidth(5)
                
        local seq = CCSequence(CCScaleBy(0.3, 1.1), CCScaleBy(0.3, 1/1.1))
        bg:runAction(CCRepeatForever(CCEaseSineInOut(seq)))
    end
    
    -- heart toggle button
    do
        local function onSelected(i)
            self.statusLabel:setString(i:selectedItem().tag)
        end
        
        local i1s1 = CCSprite("Small World:Heart")
        local i1s2 = CCSprite("Small World:Heart")
        i1s2:setColor(128, 128, 128)
        local item1 = CCMenuItemSprite(i1s1, i1s2)
        item1.tag = "Red"
        
        local i2s1 = CCSprite("Small World:Heart Gold")
        local i2s2 = CCSprite("Small World:Heart Gold")
        i2s2:setColor(128, 128, 128)        
        local item2 = CCMenuItemSprite(i2s1, i2s2)
        item2.tag = "Gold"
                
        local toggle = CCMenuItemToggle(item1, item2)
        toggle:setHandler(onSelected)
        menu:addChild(toggle)
                
        local s = 5
        toggle:setScale(5)                
        toggle:setPosition((toggle:contentSize().x * s) * 0.5 + 20, size.y/2)
    end
end

function MyLayer:itemSelected(item)
    self.statusLabel:setString(item.tag or "")
end

function MyLayer:cleanup()
    CCLayer.cleanup(self)
    self.statusLabel = nil
end