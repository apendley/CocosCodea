BatchNodeTest = CCClass(CCLayer)

function BatchNodeTest:init()
    CCLayer.init(self)
    
    --local img = readImage("Planet Cute:Character Boy")

    local bn = CCSpriteBatchNode("Planet Cute:Character Boy")
    --local bn = CCSpriteBatchNode(img)
    bn:setPosition(self:position():unpack())
    bn:setAnchor(self:anchor():unpack())
    bn:setSize(self:size():unpack())
    bn:setIgnoreAnchorForPosition(self:ignoreAnchorForPosition())
    self:addChild(bn)
    self.batchNode = bn
    
    local x, y = 45, HEIGHT - 50
    for i = 1, 100 do
        local s1 = CCSprite("Planet Cute:Character Boy")
        --local s1 = CCSprite("Planet Cute:Character Pink Girl")
        --local s1 = CCSprite(img)
        s1:setPosition(x, y)
        bn:addChild(s1, 0, i)
        --self:addChild(s1, 0, i)
        
        if math.mod(i, 20) == 0 then
            x = 45
            y = y -50
            --y = y - 20
        else
            x = x + 35
        end
       
        if math.mod(i, 3) == 0 then 
            s1:runAction{CCRotateBy(2, 360), loop=true}
        end
        --s1:runAction(CCFadeOut(10))
        --s1:runAction{CCScaleTo(.5, 1.2), CCDelay(.5), CCScaleTo(.5, 1), loop=true}
        --s1:runAction(CCTintTo(10, 128, 128, 128))
    end
    
    local function removeDude(tag)
        print("removing dude")
        bn:removeChildByTag(tag)
        --self:removeChildByTag(3)
    end
    

    ---[[
    self:runAction{CCDelay(2), CCCall(removeDude, 3)}
    self:runAction{CCDelay(4), CCCall(removeDude, 50)}
    self:runAction{CCDelay(6), CCCall(removeDude, 99)}
    self:runAction{CCDelay(8), CCCall(removeDude, 11)}    
    --]]
    
    local function addNewDude()
        local s1 = CCSprite("Planet Cute:Character Boy")
        s1:setPosition(WIDTH/2, 200)
        --s1:setFlipY(true)
        --s1:setOpacity(128)
        bn:addChild(s1, 0, 300)  
        --self:addChild(s1, 0, 300)
        --s1:runAction{CCRotateBy(2, 360), loop=true}      
        
        local s2 = CCSprite("Planet Cute:Character Boy")
        print(s1:size())
        s2:setPosition(s1:size()/2)
        s2:setPosition(s2:position() + vec2(0, 100))
        s1:addChild(s2, -1, 400)
        
    end

    self:runAction{CCDelay(3), CCCall(addNewDude)}
end

