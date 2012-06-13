CCLayer = CCClass(CCNode):include(CCTargetedTouchProtocol)

-- convenience function to wrap a layer up in scene
function CCLayer:scene(...)
    local scene = CCScene()
    scene:addChild(self(...))
    return scene
end

function CCLayer:init(w, h)
    CCNode.init(self)
    CCTargetedTouchProtocol.init(self)
    self:setAnchorPoint(0.5, 0.5)
    self:setContentSize(w or WIDTH, h or HEIGHT)
    self:setIgnoreAnchorPointForPosition(true)
end

function CCLayer:onEnter()
    CCNode.onEnter(self)
    CCTargetedTouchProtocol.onEnter(self)
end

function CCLayer:onExit()
    CCTargetedTouchProtocol.onExit(self)    
    CCNode.onExit(self)
end

----------------------
-- LayerColor class
----------------------
CCLayerColor = CCClass(CCLayer):include(CCRGBAProtocol)

-- can't take vararg color here, must pass a ccc4() object
function CCLayerColor:init(color4, w, h)
    CCLayer.init(self)
    CCRGBAProtocol.init(self, color4)
end

function CCLayerColor:draw()
    local c = self.color_    
    fill(c.r, c.g, c.b, c.a)    
    rectMode(CORNER)
    noStroke()

    local s = self.contentSize_ 
    rect(0, 0, s.x, s.y)
end