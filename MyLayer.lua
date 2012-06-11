MyLayer = CCClass(CCLayer)

function MyLayer:init()
    CCLayer.init(self)
    
    local card1 = CCSprite("Small World:Church")
    card1:setPosition(self:contentSize() / 2)
    self:addChild(card1)
    
    local pulseSeq = CCSequence:actions(CCScaleBy(0.3, 1.1), CCScaleBy(0.3, 1/1.1))
    pulseSeq = CCRepeatForever(CCEaseSineInOut(pulseSeq))
    card1:runAction(pulseSeq)
    
    self.numTimes = 3
    self:schedule("doSomething", 0.5)
    self:schedule("doSomethingElse", 0.75, 2, 1.5)
    self:schedule("update")
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