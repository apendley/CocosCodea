CCScene = CCClass(CCNode)

function CCScene:init(layer)
    CCNode.init(self)
    self:setIgnoreAnchorPointForPosition(true)
    self:setAnchorPoint(0.5,0.5)
    self:setContentSize(CCSharedDirector():winSize())
end