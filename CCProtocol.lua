--CCProtocol

-----------------------------------------------------------
-- CCRGBAProtocol
--
-- includers must forward init to CCRGBAProtocol
-----------------------------------------------------------
CCRGBAProtocol = {}

ccSynthesizeColor{CCRGBAProtocol, "color"}
ccSynthesizeColor{CCRGBAProtocol, "colorRaw", "color_"}

function CCRGBAProtocol:init(...)
    self.color_ = color(ccColorVA(...))
end

function CCRGBAProtocol:setOpacity(o)
    self.color_.a = o
end

function CCRGBAProtocol:opacity()
    return self.color_.a
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

ccSynthesize{CCTargetedTouchProtocol, "isTouchEnabled", mode="r"}

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
        CCDirector:instance():touchDispatcher():removeDelgate(self)
    end
end

function CCTargetedTouchProtocol:registerWithTouchDispatcher()
    CCDirector:instance():touchDispatcher():addTargetedDelegate(self, 0, true)
end

function CCTargetedTouchProtocol:setTouchEnabled(enabled)
    if self.isTouchEnabled_ ~= enabled then
        self.isTouchEnabled_ = enabled
        if self.isRunning_ then
            if enabled then 
                self:registerWithTouchDispatcher()
            else 
                CCDirector:instance():touchDispatcher():removeDelegate(self)
            end
        end
    end
end

function CCTargetedTouchProtocol:ccTouchBegan(touch)
    return false
end

-----------------------------------------------------------------------
-- CCLabelProtocol
-----------------------------------------------------------------------
CCLabelProtocol = {}

ccSynthesize{CCLabelProtocol, "string", "labelString_"}

function CCLabelProtocol:init(str)
    self:setString(str)
end
