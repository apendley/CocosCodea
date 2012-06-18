--CCAction

-- A Lua-fied way to run multiple actions. use like so:
-- options are: "instant", "loop", "repeat", and "ease".
-- "ease"'s value should be the name of the class that handles the easing, e.g. CCEaseIn
-- priority of options is instant > loop > repeat
-- "ease" will be ignored if "instant" is true
-- if "repeat" is specified, it's value should be the number of additional times to run
-- some ease functions take a rate. for those, specify the "rate".
-- if no options are specified, a non-repeating non-eased sequenced action is used.
-- you can also specify a tag for your actions
--
--    local action = ccAction
--    {
--        [instant = true][loop = true][repeat = 3],
--        [ease = CCEaseInOut, [rate = .3]],
--        [tag = "beefy"],
--
--        CCMoveBy(2, 100, 50),
--        CCMoveBy(2, -100, 50),
--        ...
--    }
--
-- or even:
--
--    node:runAction 
--    {
--        [instant = true][loop = true][repeat = 3],
--        [ease = CCEaseInOut, [rate = .3]],
--        [tag = "beefy"],
--
--        CCMoveBy(2, 100, 50),
--        CCMoveBy(2, -100, 50),
--        ...
--    }
function ccAction(t)
    ccAssert(next(t))    -- table must not be empty
    
    local action, instant = nil, false
    if t[2] then
        instant = t["instant"]
        action = instant and CCSpawn(t) or CCSequence(t)

        if not instant then
            local ease = t["ease"]
            if ease then action = ease(action, t["rate"]) end
        end
    else
        action = t[1]
    end

    if not instant then    
        if t["loop"] == true then
            return CCLoop(action)
        else
            local times = t["repeat"]
            if times then action = CCRepeat(action, times) end
        end
    end
    
    local tag = t["tag"]
    if tag then action:setTag(tag) end
    
    return action    
end

--------------------
-- CCAction
--------------------
CCAction = CCClass()

CCAction:synth{"tag"}

function CCAction:init()
    self.originalTarget = nil
    self.target = nil
    self.tag_ = -1
end

function CCAction:copy()
    return self.class()
end

function CCAction:startWithTarget(target)
    self.originalTarget = target
    self.target = target
end

function CCAction:stop()
    --ccPrint("CCAction:stop " .. tostring(self) .. " - setting target to nil")
    self.target = nil
end

function CCAction:isDone()
    return true
end

function CCAction:step(dt)
    -- override me
end

function CCAction:update(time)
    -- override me
end

-- implements reverse methods for reciprocal classes
function CCAction.impReverse(class1, class2)
    function class1:reverse() return class2() end
    function class2:reverse() return class1() end 
end

----------------------
-- finite time action
----------------------
CCFiniteTimeAction = CCClass(CCAction)

function CCFiniteTimeAction:init(duration)
    CCAction.init(self)
    self.duration_ = (duration ~= nil) and duration or 0
    self.elapsed = 0
end

function CCFiniteTimeAction:copy()
    return self.class(self.duration_)
end

function CCFiniteTimeAction:reverse()
    ccAssert(false, "action does not support reverse()")
end

function CCFiniteTimeAction:duration()
    return self.duration_
end

----------------------
-- repeat forever
----------------------
CCLoop = CCClass(CCAction)

function CCLoop:init(action)
    CCAction.init(self)    
    self.action_ = action
end

function CCLoop:copy()
    return CCLoop(self.action_:copy())
end

function CCLoop:reverse()
    return CCRepeatForver(self.action_:reverse())
end

function CCLoop:isDone()
    return false
end

function CCLoop:startWithTarget(target)
    CCAction.startWithTarget(self, target)
    self.action_:startWithTarget(target)
end

function CCLoop:step(dt)
    local action = self.action_
    action:step(dt)
    if action:isDone() then
        local diff = action.elapsed - action.duration_
        action:startWithTarget(self.target)
        
        -- to prevent jerk, according to cocos2d-iphone
        action:step(0)
        action:step(diff)
    end
end

----------------------
-- speed
----------------------
CCSpeed = CCClass(CCAction)

function CCSpeed:init(action, speed)
    CCAction.init(self)
    self.action_ = action
    self.speed_ = speed
end

function CCSpeed:copy()
    return CCSpeed(self.action_:copy(), self.speed_)
end

function CCSpeed:reverse()
    return CCSpeed(self.action_:reverse(), self.speed_)
end

function CCSpeed:isDone()
    return self.action_:isDone()
end

function CCSpeed:stop()
    self.action_:stop()
    CCAction.stop(self)
end

function CCSpeed:startWithTarget(target)
    CCAction.startWithTarget(self, target)
    self.action_:startWithTarget(target)
end

function CCSpeed:step(dt)
    self.action_:step(dt * self.speed_)
end

-- TODO: Follow
