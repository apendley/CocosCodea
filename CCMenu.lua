CCMenu = CCClass(CCLayer):include(CCRGBAMixin)

kCCMenuHandlerPriority = -128

CCMenu:synth{"isEnabled", set="setEnabled"}

local kCCMenuStateWaiting = 0
local kCCMenuStateTrackingTouch = 1

function CCMenu:init(...)
    CCLayer.init(self)
    CCRGBAMixin.init(self)
    
    self:setTouchEnabled(true)
    self:setEnabled(true)
    
    self:setIgnoreAnchorPointForPosition(true)
    self:setAnchorPoint(0.5, 0.5)
    -- todo: get these from the director
    self:setContentSize(WIDTH, HEIGHT)        
    self:setPosition(WIDTH/2, HEIGHT/2)
    
    if #arg > 0 then
        local z = 0
        for i,item in ipairs(arg) do
            self:addChild(item, z)
            z = z + 1
        end
    end
    
    self.selectedItem_ = nil
    self.state_ = kCCMenuStateWaiting
end

function CCMenu:addChild(child, z, tag)
    ccAssert(child:instanceOf(CCMenuItem))
    CCLayer.addChild(self, child, z, tag)
end

function CCMenu:onExit()
    if self.state_ == kCCMenuStateTrackingTouch then
        self.selectedItem:unselected()
        self.state_ = kCCMenuStateWaiting
        self.selectedItem_ = nil
    end
    
    CCLayer.onExit(self)
end

function CCMenu:setHandlerPriority(newPri)
    CCSharedDirector():touchDispatcher():setPriority(self, newPri)
end

function CCMenu:registerWithTouchDispatcher()
    local d = CCSharedDirector():touchDispatcher()
    d:addTargetedDelegate(self, kCCMenuHandlerPriority, true)
end

function CCMenu:itemForTouch(touch)
    local p = ccVec2(touch.x, touch.y)
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
    CCCRGBAMixin.setOpacity(o)
    
    for i, item in ipairs(self.children) do
        item:setOpacity(o)
    end
end

function CCMenu:setColor(c)
    CCCRGBAMixin.setColor(c)
    
    for i, item in ipairs(self.children) do
        item:setColor(c)
    end    
end

function CCMenu:setColor4(c)
    CCCRGBAMixin.setColor4(c)
    
    for i, item in ipairs(self.children) do
        item:setColor4(c)
    end        
end

------------------------
-- alignment
------------------------
local kDefaultPadding = 5

function CCMenu:alignItemsVertically(padding)
    padding = padding or kDefaultPadding
    local children = self.children
    
    local height = -padding
    
    for i, item in ipairs(children) do
        height = height + item:contentSize().y * item:scaleY() + padding
    end
    
    local y = height / 2
    
    for i, item in ipairs(children) do
        local size = item:contentSize()
        local sy = item:scaleY()
        item:setPosition(0, y - size.y * sy / 2)
        y = y - size.y * sy + padding
    end
end

function CCMenu:alignItemsHorizontally(padding)
    padding = padding or kDefaultPadding
    local children = self.children
    
    local width = -padding
    
    for i, item in ipairs(children) do
        width = width + item:contentSize().x * item:scaleX() + padding
    end
    
    local x = -width / 2
    
    for i, item in ipairs(children) do
        local size = item:contentSize()
        local sx = item:scaleX()
        item:setPosition(x + size.x * sx / 2, 0)
        x = x + size.x * sx + padding
    end
end