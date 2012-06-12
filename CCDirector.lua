CCDirector = CCClass()

ccSynthesize{CCDirector, "scheduler"}
ccSynthesize{CCDirector, "actionManager"}
ccSynthesize{CCDirector, "touchDispatcher"}

-- singleton
local directorInstance = nil
function CCDirector:instance(_)
    if not directorInstance then directorInstance = CCDirector() end
    return directorInstance
end

function CCDirector:init()
    self.actionManager_ = CCActionManager()
    self.scheduler_ = CCScheduler()
    self.touchDispatcher_ = CCTouchDispatcher()
    --self.scheduler:scheduleSelector("update", self.actionManager)
    --self.runningScene_ = nil
    --self.nextScene_ = nil
    self.nextDeltaTimeZero_ = false
    self.isPaused_ = false
    self.isAnimating_ = false
    self.sendCleanupToScene_ = false
    
    self.sceneStack_ = {}
end

function CCDirector:winSize()
    return WIDTH, HEIGHT
end

function CCDirector:runWithScene(scene)
    self:pushScene(scene)
    self:startAnimation()
end

function CCDirector:pushScene(scene)
    self.sendCleanupToScene_ = false
    
    table.insert(self.sceneStack_, scene)
    self.nextScene_ = scene
end

function CCDirector:popScene(scene)
    local sceneStack = self.sceneStack_    
    table.remove(sceneStack, #sceneStack)
    
    local c = #sceneStack    
    if c == 0 then
        self:finish()
    else
        self.sendCleanupToScene_ = true
        self.nextScene_ = sceneStack[c]
    end
end

function CCDirector:replaceScene(scene)
    local sceneStack = self.sceneStack_
    local lastIdx = #sceneStack
    self.sendCleanupToScene_ = true
    self.sceneStack_[#sceneStack] = scene
    self.nextScene_ = scene
end

-- renamed from "end" because end is a reserved keyword in Lua
function CCDirector:finish()
    self.runningScene_:onExit()
    self.runningScene_:cleanup()
    self.runningScene_ = nil
    self.actionManager_ = nil
    self.scheduler_ = nil
    self.touchDispatcher_ = nil
    
    self.sceneStack_ = {}
    
    self:stopAnimation()
    
    -- todo: release/clear any caches
end

function CCDirector:setNextScene()
    -- todo: transition handling;
    local newIsTransition = false
    local runningIsTransition = false
    
    if newIsTransition == false and self.runningScene_ then
        self.runningScene_:onExit()
        
        if self.sendCleanupToScene then
            self.runningScene_:cleanup()
        end
    end
    
    self.runningScene_ = self.nextScene_
    self.nextScene_ = nil
    
    if runningIsTransition == false then
        self.runningScene_:onEnter()
        self.runningScene_:onEnterTransitionDidFinish()
    end
end

function CCDirector:pause()
    self.isPaused_ = true
end

function CCDirector:resume()
    self.isPaused_ = false
    self.deltaT = 0
end

function CCDirector:stopAnimation()
    self.isAnimating_ = false
end

function CCDirector:startAnimation()
    self.isAnimating_ = true
end

function CCDirector:drawScene(dt)
    if self.isAnimating_ == false then return end
    
    self.touchDispatcher_:updatePreDraw()
    
    if not self.isPaused_ then
        -- uh where do i get delta time...
        self.actionManager_:update(dt)
        self.scheduler_:update(dt)
    end
    
    if self.nextScene_ then
        self:setNextScene()
    end
    
    if self.runningScene_ then
        self.runningScene_:visit()
    end
    
    self.touchDispatcher_:updatePostDraw()
end

function CCDirector:convertToUI(p)
    return p
end

function CCDirector:convertToGL(p)
    return p
end
