--MyLayer
MyLayer = CCClass(CCLayer)

function MyLayer:init()
    CCLayer.init(self)
    
    --self:setTouchEnabled(true)
    
    local orig = "Playing Cards:A_S"
    --local orig = "Small World:Mine Large"
    --local orig = "Planet Cute:Chest Closed"    
    --local orig = "Tyrian Remastered:Boss B"
    --local img = readImage(orig)
   
    --[[
    local n = CCSprite(orig)
    n:setPosition(self:contentSize()/2)
    self:addChild(n, 0, 1)
    --]]
    

    ---[[ 
    local menu = CCMenu()
    menu:setContentSize(self:contentSize())
    menu:setPosition(self:position())
    menu:setAnchorPoint(self:anchorPoint())
    self:addChild(menu)
    
    
    local normal = CCSprite("Playing Cards:A_S")
    local selected = CCSprite("Playing Cards:A_S")
    selected:setColor(255, 128, 128)
    local fn = function(item) self:itemSelected(item) end
    local item = CCMenuItemSprite(normal, selected, nil, fn)
    local pos = self:contentSize()/2
    pos.x = pos.x - 100
    item:setPosition(pos)
    item.tag = 1
    item.userData = "Left Button"
    menu:addChild(item)
    
    -- button made of rect nodes
    normal = CCNodeRect(200, 200, color(255, 255, 255))
    selected = CCNodeRect(200, 200, color(0, 255, 0))
    item = CCMenuItemSprite(normal, selected, nil, fn)
    pos = self:contentSize()/2
    pos.x = pos.x + 100
    item:setPosition(pos)
    item.tag = 2
    item.userData = "Right Button"
    menu:addChild(item)    
    --]]
    
    --[[
    local card1 = CCSprite("Small World:Court")
    card1:setPosition(self:contentSize() / 2)
    self:addChild(card1)
    
    local pulseSeq = CCSequence:actions(CCScaleBy(0.3, 1.1), CCScaleBy(0.3, 1/1.1))
    pulseSeq = CCRepeatForever(CCEaseSineInOut(pulseSeq))
    card1:runAction(pulseSeq)
    
    self.numTimes = 3
    self:schedule("doSomething", 0.5)
    self:schedule("doSomethingElse", 0.75, 2, 1.5)
    self:schedule("update")
    --]]
end

function MyLayer:itemSelected(item)
    print(item.userData .. " selected!")
end

function MyLayer:doSomething(dt)
    print("Doing Something!   " .. dt)    
    self.numTimes = self.numTimes - 1
    if self.numTimes <= 0 then self:unschedule("doSomething") end
end

function MyLayer:doSomethingElse(dt)
    print("Doing Something Else!   " .. dt)
end

function MyLayer:update(dt)
    self.updateTime = self.updateTime and (self.updateTime + dt) or dt
    self.updateText = "Update: " .. self.updateTime
end

function MyLayer:draw()
    CCLayer.draw(self)
    if self.updateText then
        text(self.updateText, 100, 100)
    end
end

--]]
function MyLayer:ccTouched(touch)
    if touch.state == BEGAN then
        local p = vec2(touch.x, touch.y)
        p = CCDirector:instance():convertToGL(p)
    
        local obj = self:getChildByTag(1)
        if obj then
            local cs = obj:contentSize()
            local r = ccRect(0, 0, cs.x, cs.y)
        
            if r:containsPoint(obj:convertToNodeSpace(p)) then
                return true
            end
        end        
    elseif touch.state == MOVING then
        local obj = self:getChildByTag(1)
        if not obj then return end    

        local pos = obj:position()
        pos.x = pos.x + touch.deltaX
        pos.y = pos.y + touch.deltaY
        obj:setPosition(pos)        
    end
end
--]]

function MyLayer:ccTouchBegan(touch)
    local p = vec2(touch.x, touch.y)
    p = CCDirector:instance():convertToGL(p)
    
    local obj = self:getChildByTag(1)
    if not obj then return false end
    
    local cs = obj:contentSize()
    local r = ccRect(0, 0, cs.x, cs.y)
        
    if r:containsPoint(obj:convertToNodeSpace(p)) then
        return true
    end
    
    return false
end

function MyLayer:ccTouchMoved(touch)
    local obj = self:getChildByTag(1)
    if not obj then return end    

    local pos = obj:position()
    pos.x = pos.x + touch.deltaX
    pos.y = pos.y + touch.deltaY
    obj:setPosition(pos)
end
