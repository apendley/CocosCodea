MenuArrangeTest = CCClass(CCLayer)

function MenuArrangeTest:init()
    CCLayer.init(self)
    
    local size = self:size()
    
    local function nextScene()
        local t = CCTransitionFade(0.75, MyLayer:scene(), 0, 0, 128)
        CCSharedDirector():replaceScene(t)
    end
    
    -- the horizontally aligned
    do
        local menu = CCMenu()
        menu:setPosition(size.x/2, size.y - 40)
        self:addChild(menu)
        
        for i = 1, 5 do
            local n = CCSprite("Planet Cute:Chest Closed")
            local s = CCSprite("Planet Cute:Chest Closed")
            s:setColor(128)
            local item = CCMenuItemSprite(n, s)
            item:setScale(ContentScaleFactor)
            menu:addChild(item, 0, i)
            
            local label = CCLabelTTF(tostring(i))
            label:setPosition(item:size()/2)
            label:setHasShadow(true)
            item:addChild(label)
            
            if i == 4 then
                item:setHandler(nextScene)
            end
        end
    
        menu:alignItemsHorizontally(30)
    end
    
    -- vertically aligned
    do
        local menu = CCMenu()
        menu:setPosition(-40, size.y/2 - 200)
        self:addChild(menu)

        for i = 1, 5 do
            local n = CCSprite("Planet Cute:Key")
            local s = CCSprite("Planet Cute:Key")
            s:setColor(128)
            local item = CCMenuItemSprite(n, s)
            item:setScale(ContentScaleFactor)
            menu:addChild(item, 0, i)
            menu:setScale(.75)
            
            local label = CCLabelTTF(tostring(i))
            label:setHasShadow(true)
            label:setPosition(item:size()/2)
            item:addChild(label)                        
        end
    
        menu:alignItemsVertically(30)
    end    
    
    -- rows
    do
        local menu = CCMenu()
        menu:setPosition(size.x/2, size.y/2 + 100)
        
        
        self:addChild(menu)

        for i = 1, 10 do
            sprite("SpaceCute:Health Heart")
            local n = CCSprite("SpaceCute:Health Heart")
            local s = CCSprite("SpaceCute:Health Heart")
            s:setColor(128)
            local item = CCMenuItemSprite(n, s)
            item:setScale(ContentScaleFactor)
            menu:addChild(item, 0, i)
            
            local label = CCLabelTTF(tostring(i))
            label:setHasShadow(true)            
            label:setPosition(item:size()/2)
            item:addChild(label)
        end
    
        menu:alignItemsInRows(5, 5)
    end        
    
    -- columns
    do
        local menu = CCMenu()
        menu:setPosition(size.x/2, size.y/2 - 250)
        
        self:addChild(menu)

        for i = 1, 12 do
            local n = CCSprite("SpaceCute:Health Heart")
            local s = CCSprite("SpaceCute:Health Heart")
            s:setColor(128)
            local item = CCMenuItemSprite(n, s)
            item:setScale(ContentScaleFactor)
            menu:addChild(item, 0, i)
            
            local label = CCLabelTTF(tostring(i))
            label:setHasShadow(true)            
            label:setPosition(item:size()/2)
            item:addChild(label)
        end
    
        menu:alignItemsInColumns(4, 4, 4)
    end            
end