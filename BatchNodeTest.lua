BatchNodeTest = CCClass(CCLayer)

--local imageName = "Planet Cute:Character Boy"
local imageName = "Playing Cards:A_S"
--local imageName = "Tyrian Remastered:Blimp Boss"

function BatchNodeTest:init()
    CCLayer.init(self)

    local bn = CCSpriteBatchNode(imageName)
    --local bn = CCSpriteBatchNode(img)
    bn:setPosition(self:position():unpack())
    bn:setAnchor(self:anchor():unpack())
    bn:setSize(self:size():unpack())
    bn:setIgnoreAnchorForPosition(self:ignoreAnchorForPosition())
    self:addChild(bn)
    self.batchNode = bn
    
    local s1 = CCSprite(imageName)
    s1:setPosition(WIDTH/2, HEIGHT/2)
    local s = s1:size()
    s1:setFlipY(true)
    s1:setTextureRect(ccRect(0, s.y*0.5, s.x, s.y*.5), false, s)
    bn:addChild(s1, 0, 300)  
    --self:addChild(s1, 0, 300)
    --s1:runAction{CCRotateBy(2, 360), loop=true}      
  
end

