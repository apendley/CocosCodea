CCActionEase = CCClass(CCActionInterval)

function CCActionEase:init(action)
    --ccPrint("ActionEase: duration is " .. action.duration)
    CCActionInterval.init(self, action.duration_)
    self.action = action
end

function CCActionEase:copy(action)
    return CCActionEase(self.action:copy())
end

function CCActionEase:startWithTarget(target)
    CCActionInterval.startWithTarget(self, target)
    self.action:startWithTarget(self.target)
end

function CCActionEase:stop()
    self.action:stop()
    CCActionInterval.stop(self)
end

function CCActionEase:update(t)
    self.action:update(t)
end

function CCActionEase:reverse()
    return CCActionEase(self.other:reverse())
end

--------------------
-- ease rate action
--------------------
CCEaseRateAction = CCClass(CCActionEase)

function CCEaseRateAction:init(action, rate)
    CCActionEase.init(self, action)
    self.rate = rate
end

function CCEaseRateAction:copy()
    return CCEaseRateAction(self.action, self.rate)
end

function CCEaseRateAction:reverse()
    return CCEaseRateAction(self.action:reverse(), 1/self.rate)
end

--------------------
-- ease in
--------------------
CCEaseIn = CCClass(CCEaseRateAction)

function CCEaseIn:update(t)
    self.action:update(math.pow(t, self.rate))
end

--------------------
-- ease out 
--------------------
CCEaseOut = CCClass(CCEaseRateAction)

function CCEaseOut:update(t)
    self.action:update(math.pow(t, 1/self.rate))
end

--------------------
-- ease in out
--------------------
CCEaseInOut = CCClass(CCEaseRateAction)

function CCEaseInOut:update(t)
    t = t * 2
    
    local rate = (t < 1) and (0.5 * pow(t,self.rate)) or (1 - 0.5 * pow(2-t, self.rate))
    self.action:update(rate)
end

function CCEaseInOut:reverse()
    return CCEaseInOut(self.action:reverse(), self.rate)
end

------------------------
-- ease exponential in
------------------------
CCEaseExponentialIn = CCClass(CCActionEase)

function CCEaseExponentialIn:update(t)
    self.action:update((t==0) and 0 or math.pow(2, 10 * (t - 1)) - 1 * 0.001)
end

function CCEaseExponentialIn:reverse()
    return CCEaseExponentialOut(self.action:reverse()) 
end

------------------------
-- ease exponential out
------------------------
CCEaseExponentialOut = CCClass(CCActionEase)

function CCEaseExponentialOut:update(t)
    self.action:update((t==1) and 1 or (1 - math.pow(2, -10 * t)))
end

function CCEaseExponentialOut:reverse()
    return CCEaseExponentialIn(self.action:reverse()) 
end


------------------------
-- ease exponential in
------------------------
CCEaseExponentialInOut = CCClass(CCActionEase)

function CCEaseExponentialInOut:update(t)
    t = t * 2    
    t = (t < 1) and (math.pow(2, 10*(t-1))) or (2 - math.pow(2, -10*(t-1)))
    t = t * 0.5
    
    self.action:update(t)
end


------------------------
-- ease sine in
------------------------
CCEaseSineIn = CCClass(CCActionEase)

function CCEaseSineIn:update(t)
    self.action:update(-1 * math.cos(t * (math.pi*0.5) + 1))
end

function CCEaseSineIn:reverse()
    return CCEaseSineOut(self.action:reverse())
end

------------------------
-- ease sine out
------------------------
CCEaseSineOut = CCClass(CCActionEase)

function CCEaseSineOut:update(t)
    self.action:update(math.sin(t * (math.pi*0.5)))
end

function CCEaseSineOut:reverse()
    return CCEaseSineIn(self.action:reverse())
end

------------------------
-- ease sine in out
------------------------
CCEaseSineInOut = CCClass(CCActionEase)

function CCEaseSineInOut:update(t)
    local pret = t
    t = -0.5 * (math.cos(math.pi*t) - 1)
    --ccPrint(tostring(self) .. " - EaseSineInOut: " .. pret .. " -> " .. t)
    self.action:update(t)
end
