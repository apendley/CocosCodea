--CCProtocol

-----------------------------------------------------------
-- CCRGBAProtocol
--
-- includers must forward init to CCRGBAProtocol
-----------------------------------------------------------
CCRGBAProtocol = {}

function CCRGBAProtocol:init(...)
    if #arg == 0 then
        self.color_ = color(255, 255, 255, 255)
    elseif #arg == 1 then    
        local c = arg[1]
        self.color_ = color(c.r, c.g, c.b, c.a)
    elseif #arg >= 3 then
        self.color_ = color(unpack(arg))
    else
        assert(false, "CCRGBAProtocol:init -> invalid parameters")
    end
end
    
function CCRGBAProtocol:setColor(...)
    local mine = self.color_
    
    if #arg >= 3 then
        mine.r, mine.g, mine.b = unpack(arg)
    elseif #arg == 1 then
        mine.r, mine.g, mine.b = ccUnpackColor(arg[1])
    else
        assert(false, "setColor usage: setColor(r, g, b) or setColor(color)")
    end
end

function CCRGBAProtocol:color()
    return ccCopyColor(self.color_)
end

function CCRGBAProtocol:setOpacity(o)
    self.color_.a = o
end

function CCRGBAProtocol:opacity()
    return self.color_.a
end

function CCRGBAProtocol:setColorRaw(...)
    local mine = self.color_
    
    if #arg >= 3 then
        mine.r, mine.g, mine.b, mine.a = unpack(arg)
        mine.a = mine.a ~= nil and mine.a or 255
    elseif #arg == 1 then
        mine.r, mine.g, mine.b, mine.a = ccUnpackColorRaw(arg[1])
    else
        assert(false, "setColor usage: setColorRaw(r, g, b, [a]) or setColorRaw(color)")
    end
end

function CCRGBAProtocol:colorRaw()
    return ccCopyColorRaw(self.color_)
end

-----------------------------------------------------------------------
-- CCTargetedTouchProtocol
--
-- includers must forward init, onEnter, and onExit to CCRGBAProtocol
--
-- * includer should implement registerWithTouchDispatcher for not-default
--   priority or of it doesn't want to swallow touches
--
-- * include must implement either ccTouched or ccTouchBegan, with
--   ccTouched having precedence if implemented
-----------------------------------------------------------------------
CCTargetedTouchProtocol = {}

function CCTargetedTouchProtocol:init()
    self.isTouchEnabled_ = false
end

function CCTargetedTouchProtocol:onEnter()
    if self.isTouchEnabled_ then
        self:registerWithTouchDispatcher()
    end
end

function CCTargetedTouchProtocol:onExit()
    if self.isTouchEnabled_ then
        CCTouchDispatcher:instance():removeDelgate(self)
    end
end

function CCTargetedTouchProtocol:isTouchEnabled()
    return self.isTouchEnabled_
end

function CCTargetedTouchProtocol:registerWithTouchDispatcher()
    CCTouchDispatcher:instance():addTargetedDelegate(self, 0, true)
end

function CCTargetedTouchProtocol:setTouchEnabled(enabled)
    if self.isTouchEnabled_ ~= enabled then
        self.isTouchEnabled_ = enabled
        if self.isRunning_ then
            if enabled then 
                self:registerWithTouchDispatcher()
            else 
                CCTouchDispatcher:instance():removeDelegate(self)
            end
        end
    end
end

function CCTargetedTouchProtocol:ccTouchBegan(touch)
    return false
end
