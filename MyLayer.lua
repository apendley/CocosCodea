--MyLayer
MyLayer = CCClass(CCLayer)

function MyLayer:init()
    CCLayer.init(self)
    
    self:setTouchEnabled(true)
    
    local orig = "Playing Cards:A_S"
    --local orig = "Small World:Mine Large"
    --local orig = "Planet Cute:Chest Closed"    
    --local orig = "Tyrian Remastered:Boss B"
    local img = readImage(orig)

    for i = 1, 1 do
        --local s = CCSprite(orig)
        local s = CCSprite(img)
        
        s:setPosition(self.contentSize_ / 2)
        self:addChild(s, 0, i)
        --[[    
        local seq = CCSequence:actions
        {
            CCDelayTime(0.1 * i),
            CCRotateBy(10, 720)
        }
        s:runAction(seq)
        --]]
    end
    
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
