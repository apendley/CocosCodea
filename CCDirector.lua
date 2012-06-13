CCDirector = CCClass()

ccProp{CCDirector, "scheduler"}
ccProp{CCDirector, "actionManager"}
ccProp{CCDirector, "touchDispatcher", mode="r"}
ccProp{CCDirector, "runningScene", mode="r"}
ccProp{CCDirector, "sendCleanupToScene", mode="r"}
ccProp{CCDirector, "showFPS", mode="rw", setter="showFPS", getter="isShowingFPS"}

-- singleton
local di_ = nil
function CCSharedDirector()
    if not di_ then di_ = CCDirector() end
    return di_
end

function CCDirector:init()
    self.scheduler_ = CCScheduler()
    self.actionManager_ = CCActionManager()    
    --self.scheduler_:scheduleSelector("update", self.actionManager_)
    self.touchDispatcher_ = CCTouchDispatcher()
    self.nextDeltaTimeZero_ = false
    self.isPaused_ = false
    self.isAnimating_ = false
    self.sendCleanupToScene_ = false
    
    self.showFPS_ = false
    self.FPS_ = 60
    self.frames_ = 0
    self.time_ = 0    
    
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
    
    --self.sceneStack_ = {}
    self.sceneStack_ = nil
    
    self:stopAnimation()
    
    -- todo: release/clear any caches
end

function CCDirector:setNextScene()
    local runningIsTransition
    if self.runningScene_ then
        runningIsTransition = self.runningScene_:instanceOf(CCTransitionScene)
    end
    
    local newIsTransition = self.nextScene_:instanceOf(CCTransitionScene)    
    
    if (not newIsTransition) and self.runningScene_ then
        self.runningScene_:onExit()
        
        if self.sendCleanupToScene_ then
            self.runningScene_:cleanup()
        end
    end
    
    self.runningScene_ = self.nextScene_
    self.nextScene_ = nil

    if not runningIsTransition then
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

function CCDirector:drawFPS(dt)
    if self.showFPS_ then 
        self.time_ = self.time_ + dt
        self.frames_ = self.frames_ + 1
    
        if self.time_ > 1 then
            self.FPS_ = self.frames_
            self.time_ = self.time_ - 1
            self.frames_ = 0
        end
    
        fill(255)
        fontSize(20)
        text("FPS:" .. self.FPS_, WIDTH - 50, 20)
    end    
end

function CCDirector:drawScene(dt)
    if self.isAnimating_ == false then self:drawFPS(dt) return end
    
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
    
    self:drawFPS(dt)
end

function CCDirector:convertToUI(p)
    return p
end

function CCDirector:convertToGL(p)
    return p
end

