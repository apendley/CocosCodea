CCScene = CCClass(CCNode)

function CCScene:init(layer)
    CCNode.init(self)
    self:setIgnoreAnchorForPosition(true)
    self:setAnchor(0.5,0.5)
    self:setSize(CCSharedDirector():winSize())
end