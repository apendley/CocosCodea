--CCTransition

CCTransitionScene = CCClass(CCScene)

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
    self.color_ = ccColor4(ccc4VA(...))    
end

function CCTransitionFade:onEnter()
    CCTransitionScene.onEnter(self)
    
    local l = CCLayerColor(self.color_)
    self.inScene_:setVisible(false)
    
    self:addChild(l, 2, kSceneFadeTag)
    l:setOpacity(0)
    
    local duration = self.duration_
    
    local sequence =
    {
        CCFadeIn(duration*0.5),
        CCCall(function() self:hideOutShowIn() end),
        CCFadeOut(duration*0.5),
        CCCall(function() self:finish() end)
    }
    l:runAction(CCSequence:actions(sequence))
end

function CCTransitionFade:onExit()
    CCTransitionScene.onExit(self)
    --self:removeChildByTag(kSceneFadeTag, false) -- uh...why false?
    self:removeChildByTag(kSceneFadeTag, true)
end