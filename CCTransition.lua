--CCTransition

CCTransitionScene = CCClass(CCScene)

ccProp{CCTransitionScene, "duration", mode="r"}

function CCTransitionScene:init(duration, scene)
    CCScene.init(self)
    
    local dir = CCSharedDirector()    
    self.duration_ = duration   
    self.inScene_ = scene
    self.outScene_ = dir:runningScene()
    ccAssert(self.inScene_ ~= self.outScene_)
    
    dir:touchDispatcher():setDispatchEvents(false)
    self:sceneOrder()
end

function CCTransitionScene:sceneOrder()
    self.inSceneOnTop_ = true
end

function CCTransitionScene:draw()
    CCScene.draw(self)
    
    if self.inSceneOnTop_ then
        self.outScene_:visit()
        self.inScene_:visit()
    else
        self.inScene_:visit()        
        self.outScene_:visit()
    end
end

function CCTransitionScene:finish()
    local inScene, outScene = self.inScene_, self.outScene_
    
    inScene:setVisible(true)
    inScene:setPosition(0,0)
    inScene:setScale(1)
    inScene:setRotation(0)
    
    outScene:setVisible(false)
    outScene:setPosition(0,0)
    outScene:setScale(1)
    outScene:setRotation(0)
    
    self:schedule("setNewScene")
end

function CCTransitionScene:setNewScene(dt)
    self:unschedule("setNewScene")
    
    local dir = CCSharedDirector()
    
    self.sendCleanupToScene_ = dir:sendCleanupToScene()
    dir:replaceScene(self.inScene_)
    dir:touchDispatcher():setDispatchEvents(true)
    self.outScene_:setVisible(true)
end

function CCTransitionScene:hideOutShowIn()
    self.inScene_:setVisible(true)
    self.outScene_:setVisible(false)
end

function CCTransitionScene:onEnter()
    CCScene.onEnter(self)
    
    self.outScene_:onExitTransitionDidStart()
    self.inScene_:onEnter()
end

function CCTransitionScene:onExit()
    CCScene.onExit(self)
    
    self.outScene_:onExit()
    self.inScene_:onEnterTransitionDidFinish()
end

function CCTransitionScene:cleanup()
    CCScene.cleanup(self)
    
    if self.sendCleanupToScene_ then
        self.outScene_:cleanup()
    end
    
    self.inScene_ = nil
    self.outScene_ = nil
end



------------------------
-- CCTransitionFade
------------------------
CCTransitionFade = CCClass(CCTransitionScene)

local kSceneFadeTag = 0xFADEFADE

-- last argument(s) is the color
function CCTransitionFade:init(duration, scene, ...)
    CCTransitionScene.init(self, duration, scene)
    self.color_ = ccc4(ccc4VA(...))    
end

function CCTransitionFade:onEnter()
    CCTransitionScene.onEnter(self)
    
    local l = CCLayerColor(self.color_)
    self.inScene_:setVisible(false)
    
    self:addChild(l, 2, kSceneFadeTag)
    l:setOpacity(0)
    
    local duration = self.duration_
    
    local sequence = CCSequence
    {
        CCFadeIn(duration*0.5),
        CCMethod(self, "hideOutShowIn"),
        CCFadeOut(duration*0.5),
        CCMethod(self, "finish")
    }
    
    l:runAction(sequence)
end

function CCTransitionFade:onExit()
    CCTransitionScene.onExit(self)
    --self:removeChildByTag(kSceneFadeTag, false) -- uh...why false?
    self:removeChildByTag(kSceneFadeTag, true)
end



-------------------------
-- CCTransitionRotoZoom
-------------------------
CCTransitionRotoZoom = CCClass(CCTransitionScene)

function CCTransitionRotoZoom:onEnter()
    CCTransitionScene.onEnter(self)
    
    local inScene = self.inScene_
    local outScene = self.outScene_
    local duration = self.duration_
    
    inScene:setScale(.001)
    outScene:setScale(1)
    
    inScene:setAnchorPoint(.5, .5)
    outScene:setAnchorPoint(.5, .5)
    
    local sequence =
    {
        CCSpawn(CCScaleBy(duration/2, .001), CCRotateBy(duration/2, 720)),
        --CCSpawn(CCRotateBy(duration/2, 720), CCScaleBy(duration/2, .001)),
        CCDelayTime(duration/2),
    }
    
    local rotozoom = CCSequence(sequence)
    outScene:runAction(rotozoom)
    inScene:runAction(CCSequence(rotozoom:reverse(), CCMethod(self, "finish")))
end

-------------------------
-- CCTransitionJumpZoom
-------------------------
CCTransitionJumpZoom = CCClass(CCTransitionScene)

function CCTransitionJumpZoom:onEnter()
    CCTransitionScene.onEnter(self)
    
    local s = CCSharedDirector():winSize()
    local inScene, outScene = self.inScene_, self.outScene_
    
    inScene:setScale(.5)
    inScene:setPosition(s.x,0)
    
    inScene:setAnchorPoint(.5, .5)
    outScene:setAnchorPoint(.5, .5)
       
    local d = self.duration_
    local d_4 = d *.25
    local jump = CCJumpBy(d_4, vec2(-s.x, 0), s.x*.25, 2)
    
    outScene:runAction(CCSequence(CCScaleTo(d_4, .5), jump))
    
    local sequence =
    {
        CCDelayTime(d*.5),
        CCSequence(jump:copy(), CCScaleTo(d_4, 1)),
        CCMethod(self, "finish")
    }
    
    inScene:runAction(CCSequence(sequence))
end

-------------------------
-- CCTransitionMoveInL
-------------------------
CCTransitionMoveInL = CCClass(CCTransitionScene)

function CCTransitionMoveInL:onEnter()
    CCTransitionScene.onEnter(self)
    self:initScenes()
    local s = self:action()
    local seq = CCSequence(self:easeActionWithAction(s), CCCallT(ccDelegate(self, "finish")))
    self.inScene_:runAction(seq)
end

function CCTransitionMoveInL:action()
    return CCMoveTo(self.duration_, 0, 0)
end

function CCTransitionMoveInL:easeActionWithAction(action)
    return CCEaseOut(action, 2)
end

function CCTransitionMoveInL:initScenes()
    local s = CCSharedDirector():winSize()
    self.inScene_:setPosition(-s.x, 0)
end

-------------------------
-- CCTransitionMoveInR
-------------------------
CCTransitionMoveInR = CCClass(CCTransitionMoveInL)

function CCTransitionMoveInR:initScenes()
    local s = CCSharedDirector():winSize()
    self.inScene_:setPosition(s.x, 0)
end

-------------------------
-- CCTransitionMoveInT
-------------------------
CCTransitionMoveInT = CCClass(CCTransitionMoveInL)

function CCTransitionMoveInT:initScenes()
    local s = CCSharedDirector():winSize()
    self.inScene_:setPosition(0, s.y)
end

-------------------------
-- CCTransitionMoveInT
-------------------------
CCTransitionMoveInB = CCClass(CCTransitionMoveInL)

function CCTransitionMoveInB:initScenes()
    local s = CCSharedDirector():winSize()
    self.inScene_:setPosition(0, -s.y)
end


-------------------------
-- CCTransitionSlideInL
-------------------------
CCTransitionSlideInL = CCClass(CCTransitionScene)

local ADJUST_FACTOR = 0.5

function CCTransitionSlideInL:onEnter()
    CCTransitionScene.onEnter(self)
    
    self:initScenes()
    
    self.inScene_:runAction(self:easeActionWithAction(self:action()))    
    
    local sequence = 
    {
        self:easeActionWithAction(self:action()),
        CCMethod(self, "finish")
    }
    
    self.outScene_:runAction(CCSequence(sequence))
end

function CCTransitionSlideInL:sceneOrder()
    local inSceneOnTop_ = false
end

function CCTransitionSlideInL:initScenes()
    local s = CCSharedDirector():winSize()
    self.inScene_:setPosition(-(s.x-ADJUST_FACTOR), 0)
end

function CCTransitionSlideInL:action()
    local s = CCSharedDirector():winSize()
    return CCMoveBy(self.duration_, s.x-ADJUST_FACTOR, 0)
end

function CCTransitionSlideInL:easeActionWithAction(action)
    return CCEaseOut(action, 2)
end

-------------------------
-- CCTransitionSlideInR
-------------------------
CCTransitionSlideInR = CCClass(CCTransitionSlideInL)

function CCTransitionSlideInR:sceneOrder()
    self.inSceneOnTop_ = true
end

function CCTransitionSlideInR:initScenes()
    local s = CCSharedDirector():winSize()
    self.inScene_:setPosition(s.x-ADJUST_FACTOR, 0)
end

function CCTransitionSlideInR:action()
    local s = CCSharedDirector():winSize()
    return CCMoveBy(self.duration_, -(s.x-ADJUST_FACTOR), 0)    
end

-------------------------
-- CCTransitionSlideInT
-------------------------
CCTransitionSlideInT = CCClass(CCTransitionSlideInL)

function CCTransitionSlideInT:sceneOrder()
    self.inSceneOnTop_ = false
end

function CCTransitionSlideInT:initScenes()
    local s = CCSharedDirector():winSize()
    self.inScene_:setPosition(0, s.y-ADJUST_FACTOR)
end

function CCTransitionSlideInT:action()
    local s = CCSharedDirector():winSize()
    return CCMoveBy(self.duration_, 0, -(s.y-ADJUST_FACTOR))
end

-------------------------
-- CCTransitionSlideInB
-------------------------
CCTransitionSlideInB = CCClass(CCTransitionSlideInL)

function CCTransitionSlideInB:sceneOrder()
    self.inSceneOnTop_ = true
end

function CCTransitionSlideInB:initScenes()
    local s = CCSharedDirector():winSize()
    self.inScene_:setPosition(0, -(s.y-ADJUST_FACTOR))
end

function CCTransitionSlideInB:action()
    local s = CCSharedDirector():winSize()
    return CCMoveBy(self.duration_, 0, s.y-ADJUST_FACTOR)
end


-------------------------
-- CCTransitionShrinkGrow
-------------------------
CCTransitionShrinkGrow = CCClass(CCTransitionScene)

function CCTransitionShrinkGrow:onEnter()
    CCTransitionScene.onEnter(self)
    
    local inScene, outScene = self.inScene_, self.outScene_
    
    inScene:setScale(.001)
    outScene:setScale(1)
    
    inScene:setAnchorPoint(2/3, .5)
    outScene:setAnchorPoint(1/3, .5)
    
    inScene:runAction(self:easeActionWithAction(CCScaleTo(self.duration_, 1)))
    
    local sequence =
    {
        self:easeActionWithAction(CCScaleTo(self.duration_, .01)),
        CCMethod(self, "finish")
    }
    
    outScene:runAction(CCSequence(sequence))
end

function CCTransitionShrinkGrow:easeActionWithAction(action)
    return CCEaseOut(action, 2)
end