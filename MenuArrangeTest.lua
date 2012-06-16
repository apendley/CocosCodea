MenuArrangeTest = CCClass(CCLayer)

function MenuArrangeTest:init()
    CCLayer.init(self)
    
    local size = self:contentSize()
    
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
            menu:addChild(item, 0, i)
            
            local label = CCLabelTTF(tostring(i))
            label:setPosition(item:contentSize()/2)
            item:addChild(label)            
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
            menu:addChild(item, 0, i)
            menu:setScale(.75)
            
            local label = CCLabelTTF(tostring(i))
            label:setPosition(item:contentSize()/2)
            item:addChild(label)                        
        end
    
        menu:alignItemsVertically(30)
    end    
    
    -- 2 rows
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
            menu:addChild(item, 0, i)
            
            local label = CCLabelTTF(tostring(i))
            label:setPosition(item:contentSize()/2)
            item:addChild(label)
        end
    
        menu:alignItemsInRows(5, 5)
    end        
    
    -- 2 columns
    do
        local menu = CCMenu()
        menu:setPosition(size.x/2, size.y/2 - 250)
        
        self:addChild(menu)

        for i = 1, 12 do
            sprite("SpaceCute:Health Heart")
            local n = CCSprite("SpaceCute:Health Heart")
            local s = CCSprite("SpaceCute:Health Heart")
            s:setColor(128)
            local item = CCMenuItemSprite(n, s)
            menu:addChild(item, 0, i)
            
            local label = CCLabelTTF(tostring(i))
            label:setPosition(item:contentSize()/2)
            item:addChild(label)
            item:setScale(.5)
        end
    
        menu:alignItemsInColumns(4, 4, 4)
    end            
end