-- CCActionInterval
CCActionInterval = CCClass(CCFiniteTimeAction)

function CCActionInterval:init(duration)
    CCFiniteTimeAction.init(self, duration or FLT_EPSILON)
    self.elapsed = 0
    self.firstTick = true
end

function CCActionInterval:isDone()
    return self.elapsed >= self.duration_
end

function CCActionInterval:step(dt)
    if self.firstTick then
        self.firstTick = false
        self.elapsed = 0
    else
        self.elapsed = self.elapsed + dt
    end
    
    local min = math.min
    local max = math.max
    local t = max(0, min(1, self.elapsed / max(self.duration_, FLT_EPSILON)))
    self:update(t)
end

function CCActionInterval:startWithTarget(target)
    CCFiniteTimeAction.startWithTarget(self, target)
    self.elapsed = 0
    self.firstTick = true
end

function CCActionInterval:reverse()
    assert(false, "IntervalAction: reverse not implemented")
end

----------------------
-- sequence
----------------------
CCSequence = CCClass(CCActionInterval)

-- convenience function, NOT a class method
function CCSequence.actions(klass, ...)    
    assert(klass == CCSequence, "Use CCSequence:actions(...) to sequence 2 or more actions")
    
    local list = (#arg == 1) and arg[1] or arg
    local prev, next = list[1], nil
    
    for i = 2, #list do
        next = list[i]
        prev = CCSequence(prev, next)
    end
        
    return prev    
end

function CCSequence:init(one, two, ...)
    --print("Adding Sequence: (" .. tostring(one) .. ") -> (" .. tostring(two) ..")\n")
    assert( #arg == 0, "Use CCSequence:actions(...) to sequence 2 or more actions")
    local duration = one.duration_ + two.duration_
    CCActionInterval.init(self, duration)
    self.actions_ = {one, two}        
end

function CCSequence:copy()
    local actions = self.actions_
    return CCSequence(actions[1]:copy(), actions[2]:copy())
end

function CCSequence:reverse()
    local actions = self.actions_
    return CCSequence(actions[2]:reverse(), actions[1]:reverse())
end

function CCSequence:startWithTarget(target)
    CCActionInterval.startWithTarget(self, target)
    self.split = self.actions_[1].duration_ / math.max(self.duration_, FLT_EPSILON)
    self.last = -1
end

function CCSequence:stop()
    if self.last ~= -1 then
        self.actions_[self.last]:stop()
    end
end

function CCSequence:update(t)
    local split = self.split
    local actions = self.actions_
    local cur, newT = 1, 0
    
    if t < split then
        newT = (split ~= 0) and t / split or 1
    else
        cur = 2
        newT = (split == 1) and 1 or ((t-split) / (1-split))
    end
    
    if cur == 2 then
        local action = actions[1]
        
        if self.last == -1 then
            -- action[1] was skipped, execute it
            action:startWithTarget(self.target)
            action:update(1)
            action:stop()
        elseif self.last == 1 then
            -- switching to action 2, stop action 1
            action:update(1)
            action:stop()
        end
    end
    
    if cur ~= self.last then
        actions[cur]:startWithTarget(self.target)
    end
    
    actions[cur]:update(newT)
    self.last = cur
end


----------------------
-- Repeat
----------------------
CCRepeat = CCClass(CCActionInterval)

function CCRepeat:init(action, times)
    assert(action ~= nil and times ~= nil)
    
    local dur = action.duration_ * times
    CCActionInterval.init(self, dur)
    
    local isInstant = action:instanceOf(CCActionInstant)
    self.isInstant_ = isInstant    
    self.times_ = isInstant and (times - 1) or times
    self.total_ = 0
    self.nextDT_ = 0
    self.action_ = action
end

function CCRepeat:copy()
    return CCRepeat(self.action_:copy(), self.times_)
end

function CCRepeat:reverse()
    return CCRepeat(self.action_:reverse(), self.times_)
end

function CCRepeat:startWithTarget(target)
    local action = self.action_
    self.total_ = 0
    self.nextDT_ = action.duration_ / self.duration_
    CCActionInterval.startWithTarget(self, target)
    action:startWithTarget(target)
end

function CCRepeat:stop()
    self.action_:stop()
    CCActionInterval.stop(self)
end

function CCRepeat:update(dt)
    local action = self.action_
    local nextDT = self.nextDT_
    local times = self.times_
    
    if dt >= nextDT then
        while (dt > nextDT) and (self.pTotal < times) do
            action:update(1)
            self.total_ = self.total_ + 1
            action:stop()
            action:startWithTarget(self.target)
            nextDT = nextDT + action.duration_ / self.duration_
            self.nextDT_ = nextDT
        end
            
        if dt >= 1 and self.total_ < times then 
            self.total_ = self.total_ + 1
        end  

        if not self.isInstant_ then
            if self.total_ == times then
                action:update(1)
                action:stop()
            else
                action:update(dt - (nextDT - action.duration_ / self.duration_))
            end
        end
    else
        action:update(math.fmod(dt * times, 1))
    end     
end

function CCRepeat:isDone()
    return self.total_ == self.times_
end

----------------------
-- Spawn
----------------------
CCSpawn = CCClass(CCActionInterval)

-- convenience function, NOT a class method
function CCSpawn.actions(klass, ...)    
    -- todo: skip self to enable . or : syntax
    assert(klass == CCSpawn, "use CCSpawn:actions(...) to spawn 2 or more actions")
    
    local list = (#arg == 1) and arg[1] or arg
    local prev, next = list[1], nil
    
    for i = 2, #list do
        next = list[i]
        prev = CCSequence(prev, next)
    end
        
    return prev    
end

function CCSpawn:init(one, two, ...)
    --print("Adding Sequence: (" .. tostring(one) .. ") -> (" .. tostring(two) ..")\n")
    assert( #arg == 0, "use CCSpawn:actions(...) to spawn 2 or more actions")
    
    local d1, d2 = one.duration_, two.duration_    
    CCActionInterval.init(self, math.max(d1, d2))
    self.one_, self.two_ = one, two
    
    if d1 > d2 then
       self.two_ = CCSequence(two, CCDelayTime(d1-d2))
    elseif d1 < d2 then
        self.one_ = CCSequence(one, CCDelayTime(d2-d1))
    end
end

function CCSpawn:copy()
    return CCSpawn(self.one_:copy(), self.two_:copy())
end

function CCSpawn:reverse()
    return CCSpawn(self.one_:reverse(), self.two_:reverse())
end

function CCSpawn:startWithTarget(target)
    CCActionInterval.startWithTarget(self, target)
    self.one_:startWithTarget(target)
    self.two_:startWithTarget(target)
end

function CCSpawn:stop()
    self.one_:stop()
    self.two_:stop()
    CCActionInterval:stop(self)
end

function CCSpawn:update(t)
    self.one_:update(t)
    self.two_:update(t)
end

----------------------
-- RotateTo
----------------------
CCRotateTo = CCClass(CCActionInterval)

function CCRotateTo:init(duration, angle)
    CCActionInterval.init(self, duration)
    self.dstAngle = angle
    self.startAngle = 0
    self.diffAngle = 0
end

function CCRotateTo:copy()
    return CCRotateTo(self.duration, self.dstAngle)
end

-- hmm...reverse is missing in cocos2d...

function CCRotateTo:startWithTarget(target)
    CCActionInterval.startWithTarget(self, target)
    
    local startAngle = target:rotation()
    local mo = (startAngle > 0) and 360 or -360
    startAngle = math.fmod(startAngle, mo)    
    self.startAngle = startAngle
    
    local diffAngle = self.dstAngle - startAngle
    local wrap = (diffAngle > 180) and -360 or 360
    diffAngle = diffAngle + wrap    
    self.diffAngle = diffAngle;    
end

function CCRotateTo:update(t)
    self.target:setRotation(self.startAngle + self.diffAngle * t)
end

----------------------
-- RotateBy
----------------------
CCRotateBy = CCClass(CCActionInterval)

function CCRotateBy:init(duration, angle)
    CCActionInterval.init(self, duration)
    self.angle = angle
end

function CCRotateBy:copy()
    return CCRotateBy(self.duration_, self.angle)
end

function CCRotateBy:reverse()
    return CCRotateBy(self.duration_, -self.angle)
end

function CCRotateBy:startWithTarget(target)
    CCActionInterval.startWithTarget(self, target)
    self.startAngle = target:rotation()
end

function CCRotateBy:update(t)
    self.target:setRotation(self.startAngle + self.angle * t)
end


----------------------
-- MoveTo
----------------------
CCMoveTo = CCClass(CCActionInterval)

function CCMoveTo:init(duration, ...)
    CCActionInterval.init(self, duration)
    
    if #arg == 1 then
        local p = arg[1]
        self.endPosition = vec2(p.x, p.y)
    else
        self.endPosition = vec2(arg[1], arg[2])
    end
end

function CCMoveTo:copy()
    return CCMoveTo(self.duration_, self.endPosition)
end

function CCMoveTo:startWithTarget(target)
    CCActionInterval.startWithTarget(self, target)
    self.startPosition = target:position()
    self.delta = self.endPosition - self.startPosition
end

function CCMoveTo:update(t)
    local sp = self.startPosition
    local ep = self.endPosition
    local dlt = self.delta
    self.target:setPosition(sp.x + dlt.x * t, sp.y + dlt.y * t)
end

----------------------
-- MoveBy
----------------------
CCMoveBy = CCClass(CCMoveTo)

function CCMoveBy:init(duration, ...)
    CCMoveTo.init(self, duration)
   
    if #arg == 1 then
        local p = arg[1]
        self.delta = vec2(p.x, p.y)
    else
        self.delta = vec2(arg[1], arg[2])
    end    
end

function CCMoveBy:copy()
    return CCMoveBy(self.duration_, self.delta)
end

function CCMoveBy:startWithTarget(target)
    local delta = self.delta
    local p = vec2(delta.x, delta.y)
    CCMoveTo.startWithTarget(self, target)
    self.delta = p
end

function CCMoveBy:reverse()
    return CCMoveBy(self.duration_, self.delta * -1)
end

function CCMoveBy:update(t)
    CCMoveTo.update(self, t)
end


-- TODO: skewBy, skewTo, JumpBy, JumpTo, BezierBy, BezierTo

----------------------
-- ScaleTo
----------------------
CCScaleTo = CCClass(CCActionInterval)

function CCScaleTo:init(duration, ...)
    CCActionInterval.init(self, duration)
    
    if #arg == 1 then
        local s = arg[1]
        self.endScaleX = s
        self.endScaleY = s 
    else
        self.endScaleX = arg[1]
        self.endScaleY = arg[2]
    end
end

function CCScaleTo:copy()
    return self.class(self.duration_, self.endScaleX, self.endScaleY)
end

function CCScaleTo:startWithTarget(target)
    CCActionInterval.startWithTarget(self, target)
    local sx = target:scaleX()
    local sy = target:scaleY()
    self.startScaleX = sx
    self.startScaleY = sy
    self.deltaX = self.endScaleX - sx
    self.deltaY = self.endScaleY - sy
end

function CCScaleTo:update(t)
    local target = self.target
    target:setScaleX(self.startScaleX + self.deltaX * t)
    target:setScaleY(self.startScaleY + self.deltaY * t)
end

----------------------
-- ScaleBy
----------------------
CCScaleBy = CCClass(CCScaleTo)

function CCScaleBy:startWithTarget(target)
    CCScaleTo.startWithTarget(self, target)
    local sx = self.startScaleX
    local sy = self.startScaleY
    self.deltaX = sx * self.endScaleX - sx
    self.deltaY = sy * self.endScaleY - sy
end

function CCScaleBy:reverse()
    return CCScaleBy(self.duration_, 1/self.endScaleX, 1/self.endScaleY)
end

----------------------
-- Blink
----------------------
CCBlink = CCClass(CCActionInterval)

function CCBlink:init(duration, blinks)
    CCActionInterval.init(self, duration)
    self.times = blinks
end

function CCBlink:copy()
    return CCBlink(self.duration_, self.times)
end

CCBlink.reverse = CCBlink.copy

function CCBlink:update(t)
    if self:isDone() then return end

    local slice = 1 / self.times
    local m = math.fmod(t, slice)
    self.target:setVisible(m > slice/2)
end


----------------------
-- tint to
----------------------
CCTintTo = CCClass(CCActionInterval)

function CCTintTo:init(duration, ...)
    CCActionInterval.init(self, duration)

    if #arg == 3 then
        local r, g, b = unpack(arg)
        self.to_ = color(r, g, b, 255)
    elseif #arg == 1 then
        self.to_ = ccCopyColor(arg[1])
    else
        assert(false, "CCTintTo usage: CCTintTo(duration, r, g, b) or CCTintTo(duration, color)")
    end
end

function CCTintTo:copy()
    return self.class(self.duration_, ccCopyColor(self.to_))
end

function CCTintTo:startWithTarget(target)
    CCActionInterval.startWithTarget(self, target)
    self.from_ = target:color()
end

function CCTintTo:update(t)
    local to = self.to_
    local from = self.from_
    local r = from.r + (to.r - from.r) * t
    local g = from.g + (to.g - from.g) * t
    local b = from.b + (to.b - from.b) * t
    self.target:setColor(r, g, b)
end

----------------------
-- tint by
----------------------
CCTintBy = CCClass(CCActionInterval)

function CCTintBy:init(duration, ...)
    CCActionInterval.init(self, duration)

    if #arg == 3 then
        local r, g, b = unpack(arg)
        self.delta_ = color(r, g, b, 255)
    elseif #arg == 1 then
        self.delta_ = ccCopyColor(arg[1])
    else
        assert(false, "CCTintBy usage: CCTintBy(duration, r, g, b) or CCTintBy(duration, color)")
    end    
end

function CCTintBy:copy()
    return self.class(self.duration_, ccCopyColor(self.delta_))
end

function CCTintBy:reverse()
    local c = self.delta_
    return self.class(self.duration_, color(-c.r, -c.g, -c.b))
end

function CCTintBy:startWithTarget(target)
    CCActionInterval.startWithTarget(self, target)
    self.from_ = target:color()
end

function CCTintBy:update(t)
    local from = self.from_
    local delta = self.delta_
    local r = from.r + delta.r * t
    local g = from.g + delta.g * t
    local b = from.b + delta.b * t
    self.target:setColor(r, g, b)
end

----------------------
-- fade in, fade out
----------------------
CCFadeIn = CCClass(CCActionInterval)
function CCFadeIn:update(t) self.target:setOpacity(255 * t) end

CCFadeOut = CCClass(CCActionInterval)
function CCFadeOut:update(t) self.target:setOpacity(255 * (1-t)) end

CCAction:ImplementReverse(CCFadeIn, CCFadeOut)

----------------------
-- fade to
----------------------
CCFadeTo = CCClass(CCActionInterval)

function CCFadeTo:init(duration, opacity)
    CCActionInterval.init(self, duration)
    self.toOpacity_ = opacity
end

function CCFadeTo:copy()
    return self.class(self.duration_, self.toOpacity_)
end

function CCFadeTo:startWithTarget(target)
    CCActionInterval.startWithTarget(self, target)
    self.fromOpacity_ = target:opacity()
end

function CCFadeTo:update(t)
    local from, to = self.fromOpacity_, self.toOpacity_
    self.target:setOpacity(from + (to - from) * t)
end

----------------------
-- DelayTime
----------------------
CCDelayTime = CCClass(CCActionInterval)
CCDelayTime.reverse = CCDelayTime.copy


-- TODO: ReverseTime, Animate, TargetedAction

