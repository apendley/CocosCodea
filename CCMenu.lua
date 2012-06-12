CCMenu = CCClass(CCLayer):include(CCRGBAProtocol)

kCCMenuHandlerPriority = -128

ccProp{CCMenu, "isEnabled", setter="setEnabled"}

local kCCMenuStateWaiting = 0
local kCCMenuStateTrackingTouch = 1

-- todo: also allow variable args
--function CCMenu:init(itemTable)
function CCMenu:init(...)
    local itemTable = (#arg == 1) and arg[1] or arg
    
    CCLayer.init(self)
    CCRGBAProtocol.init(self)
    
    self:setTouchEnabled(true)
    self:setEnabled(true)
    
    self:setIgnoreAnchorPointForPosition(true)
    self:setAnchorPoint(0.5, 0.5)
    -- todo: get these from the director
    self:setContentSize(WIDTH, HEIGHT)        
    self:setPosition(WIDTH/2, HEIGHT/2)
    
    if itemTable then
        local z = 0
        for i,item in ipairs(itemTable) do
            self:addChild(item, z)
            z = z + 1
        end
    end
    
    self.selectedItem_ = nil
    self.state_ = kCCMenuStateWaiting
end

function CCMenu:addChild(child, z, tag)
    ccAssert(child:instanceOf(CCMenuItem))
    CCMenuItem.addChild(self, child, z, tag)
end

function CCMenu:onExit()
    if self.state_ == kCCMenuStateTrackingTouch then
        self.selectedItem:unselected()
        self.state_ = kCCMenuStateWaiting
        self.selectedItem_ = nil
    end
    CCMenuItem.onExit(self)
end

function CCMenu:setHandlerPriority(newPri)
    CCSharedDirector():touchDispatcher():setPriority(self, newPri)
end

function CCMenu:registerWithTouchDispatcher()
    local d = CCSharedDirector():touchDispatcher()
    d:addTargetedDelegate(self, kCCMenuHandlerPriority, true)
end

function CCMenu:itemForTouch(touch)
    local p = vec2(touch.x, touch.y)
    p = CCSharedDirector():convertToGL(p)
    
    for i,item in ipairs(self.children) do
        if item:visible() and item:isEnabled() then
            local pl = item:convertToNodeSpace(p)
            local r = item:rect()
            r.x, r.y = 0, 0
            
            if r:containsPoint(pl) then return item end
        end
    end
end

function CCMenu:ccTouchBegan(touch)
    if self.state_ ~= kCCMenuStateWaiting or not self:visible() or not self.isEnabled_ then
        return false
    end    
            
    local c = self.parent
    while c ~= nil do
        if not c:visible() then return false end
        c = c.parent
    end
    
    self.selectedItem_ = self:itemForTouch(touch)
    
    if self.selectedItem_ then
        self.selectedItem_:selected()
        self.state_ = kCCMenuStateTrackingTouch
        return true        
    end
    
    return false
end

function CCMenu:ccTouchMoved(touch)
    ccAssert(self.state_ == kCCMenuStateTrackingTouch)
    
    local currentItem = self:itemForTouch(touch)
    
    if currentItem ~= self.selectedItem_ then
        if self.selectedItem_ then self.selectedItem_:unselected() end
        self.selectedItem_ = currentItem
        if self.selectedItem_ then self.selectedItem_:selected() end
    end
end

function CCMenu:ccTouchEnded(touch)
    ccAssert(self.state_ == kCCMenuStateTrackingTouch)
    
    if self.selectedItem_ then 
        self.selectedItem_:unselected() 
        self.selectedItem_:activate()        
    end
    
    self.state_ = kCCMenuStateWaiting    
end

function CCMenu:setOpacity(o)
    CCCRGBAProtocol.setOpacity(o)
    
    for i, item in ipairs(self.children) do
        item:setOpacity(o)
    end
end

function CCMenu:setColor(c)
    CCCRGBAProtocol.setColor(c)
    
    for i, item in ipairs(self.children) do
        item:setColor(c)
    end    
end

function CCMenu:setColorRaw(c)
    CCCRGBAProtocol.setColorRaw(c)
    
    for i, item in ipairs(self.children) do
        item:setColorRaw(c)
    end        
end

