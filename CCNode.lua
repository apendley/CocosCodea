--CCNode
CCNode = CCClass()

CCNode:synth{"visible"}
CCNode:synth{"rotation", mode="r"}
CCNode:synth{"scaleX", mode="r"}
CCNode:synth{"scaleY", mode="r"}
CCNode:synth{"scale", ivar="scaleX_", mode="r"}
CCNode:synth{"ignoreAnchorForPosition", mode="r"}
CCNode:synth{"userData"}
CCNode:synth{"actionManager", mode="r"}
CCNode:synth{"children", mode="r"}
CCNode:synth{"position", mode="#"}
CCNode:synth{"anchor", mode="#"}
CCNode:synth{"size", mode="#"}

function CCNode:init()
    self.position_ = ccVec2(0,0)
    self.anchor_ = ccVec2(0,0)
    self.anchorInPoints_ = ccVec2(0,0)
    self.ignoreAnchorForPosition_ = false
    self.size_ = ccVec2(0,0)
    self.rotation_ = 0
    self.scaleX_ = 1
    self.scaleY_ = 1
    self.zOrder_ = 0
    local xform = matrix()
    self.transform_ = xform
    self.inverse = xform:inverse()
    self.isTransformDirty_ = true
    self.isInverseDirty_ = true
    self.isRunning_ = false    
    self.visible_ = true
    
    self.tag_ = -1    
    self.children_ = {}
    
    local dir = CCSharedDirector()
    self.actionManager_ = dir:actionManager()
    self.scheduler_ = dir:scheduler()
end

local function insertChild(node, child, z)
    local children = node.children_
    local last = children[#children]
    
    if last == nil or last.zOrder <= z then
        ccArrayInsert(children, child)
    else
        for i,v in ipairs(children) do
            if last.zOrder > z then
                ccArrayInsert(children, i, child)
                break
            end
        end
    end
    
    child.zOrder = z
end

function CCNode:addChild(child, z, tagOrPair)
    insertChild(self, child, z or 0)
    if tagOrPair then child:setTag(tagOrPair) end
    child.parent_ = self
end

function CCNode:setTag(tagOrPair)
    if type(tagOrPair) == "table" then
        local key, tag = tagOrPair[1], tagOrPair[2]
        
        if self.userTags_ == nil then
            self.userTags_ = {}
        end
        
        self.userTags_[key] = tag
    else
        self.tag_ = tagOrPair
    end
end

function CCNode:tag(keyOrNil)
    if keyOrNil == nil then
        return self.tag_
    elseif self.userTags_ then
        return self.userTags_[keyOrNil]
    end
end

function CCNode:getChildByTag(tagOrPair)
    if type(tagOrPair) == "table" then
        local key, tag = tagOrPair[1], tagOrPair[2]
        
        for i,child in ipairs(self.children_) do
            if child.userTags_[key] == tag then return child end
        end            
    else
        for i,child in ipairs(self.children_) do
            if child.tag_ == tagOrPair then return child end
        end                
    end
end

function CCNode:reorderChild(child, z)
    local idx = ccArrayIndexOf(self.children_, child)
    
    if idx then        
        local c = self.children_[idx]
        ccArrayRemove(self.children_, idx)
        insertChild(self, child, z)
    end
end

function CCNode:detachChild(child, cleanup)
    if self.isRunning_ then
        child:onExitTransitionDidStart()
        child:onExit()
    end
    
    if cleanup then child:cleanup() end
        
    child.parent_ = nil
    ccArrayRemoveObject(self.children_, child)
end

function CCNode:removeChild(child, cleanup)
    if not child then return end

    --default cleanup = true
    if cleanup == nil then cleanup = true end
    
    if ccArrayContains(self.children_, child) then
        self:detachChild(child, cleanup)
    end
end

function CCNode:removeChildByTag(tagOrPair, cleanup)
    child = self:getChildByTag(tagOrPair)
    
    if child then
        -- default cleanup = true
        if cleanup == nil then cleanup = true end
        self:removeChild(child, cleanup)
    end
end

function CCNode:removeAllChildren(cleanup_)
    -- default cleanup to true
    if cleanup_ == nil then cleanup_ = true end
    
    for i, child in ipairs(self.children_) do
        if self.isRunning_ then
            child:onExitTransitionDidStart()
            child:onExit()
        end
        
        if cleanup_ then child:cleanup() end
        child.parent_ = nil
    end
    
    ccArrayClear(self.children_)
end

function CCNode:removeFromParent(cleanup_)
    if self.parent_ then
        -- default cleanup = true
        if cleanup_ == nil then cleanup_ = true end
        self.parent_:removeChild(self, cleanup_)
    end
end

function CCNode:cleanup()
    --ccPrint("cleanup: " .. tostring(self))
    self:stopAllActions()
    self:unscheduleAllSelectors()
    ccArrayForEach(self.children_, "cleanup")
    self.userData = nil
end

function CCNode:transform()
    applyMatrix( self:nodeToParentTransform() )    
end

function CCNode:visit()
    if not self.visible_ then return end
    
    pushStyle()
    pushMatrix()
    
    self:transform()
    
    local children = self.children_      
    
    -- draw children with zOrder < 0
    local cidx = 1
    while cidx <= #children do
        local c = children[cidx]
        if c.zOrder_ < 0 then
            c:visit()
            cidx = cidx + 1
        else
            break
        end
    end

    self:draw()
    
    -- draw children with zOrder >= 0
    for cidx = cidx, #children do
        local c = children[cidx]
        c:visit()        
    end
    
    popMatrix()
    popStyle()
end

function CCNode:nodeToParentTransform()
    local xform = self.transform_
    
    if self.isTransformDirty_ then
        local pos, app = self.position_, self.anchorInPoints_
        local x, y, sx, sy = pos.x, pos.y, self.scaleX_, self.scaleY_
        local c, s, angle = 1, 0, self.rotation_
        
        if angle ~= 0 then
            local rad = -math.rad(angle)
            c, s = math.cos(rad), math.sin(rad)
        end
        
        if self.ignoreAnchorForPosition_ then
            x = x + app.x
            y = y + app.y
        end        
        
        if app ~= ccVec2(0, 0) then
            x = x + (c * -app.x * sx) + (-s * -app.y * sy)
            y = y + (s * -app.x * sx) + (c * -app.y * sy)
        end
        
        xform[1] = c * sx
        xform[2] = s * sx
        xform[5] = -s * sy
        xform[6] = c * sy
        xform[13] = x
        xform[14] = y
        
        self.isTransformDirty_ = false
    end
    
    return xform
end

function CCNode:parentToNodeTransform()
    if self.isInverseDirty_ then
        self.inverse = self:nodeToParentTransform():inverse()
        self.inverseDirty_ = false
    end
    return self.inverse
end

function CCNode:nodeToWorldTransform()
    local t = self:nodeToParentTransform()
    
    local p = self.parent_    
    while p do
        t = t * p:nodeToParentTransform()
        p = p.parent_ 
    end
    
    return t
end

function CCNode:worldToNodeTransform()
    return self:nodeToWorldTransform():inverse()
end

function CCNode:convertToNodeSpace(worldPt)
    return ccAffineTransform(worldPt, self:worldToNodeTransform())
end

function CCNode:convertToWorldSpace(nodePt)
    return ccAffineTransform(nodePt, self:nodeToWorldTransform())
end

function CCNode:convertToNodeSpaceAR(worldPt)
    return self:convertToNodeSpace(worldPt) - self.anchorInPoints_
end

function CCNode:convertToWorldSpaceAR(nodePt)
    return self:convertToWorldSpace(nodePt + self.anchorInPoints_)
end

function CCNode:convertToWindowSpace(nodePt)
    local worldPt = self:convertToWorldSpace(nodePt)
    return CCSharedDirector():convertToUI(worldPt)
end

function CCNode:convertTouchToNodeSpace(tp)
    return self:convertToNodeSpace(CCSharedDirector():convertToGL(tp))
end

function CCNode:convertTouchToNodeSpaceAR(tp)
    return self:convertToNodeSpaceAR(CCSharedDirector():convertToGL(tp))
end

function CCNode:boundingBox()
    local cs = self.size_
    local r = ccRect(0, 0, cs.x, cs.y)
    return r:applyTransform(self:nodeToParentTransform())
end

--------------------
-- properties
--------------------
function CCNode:setRotation(angle)
    self.rotation_ = angle
    self.isTransformDirty_, self.isInverseDirty_ = true, true
end

function CCNode:setScaleX(s)
    self.scaleX_ = s
    self.isTransformDirty_, self.isInverseDirty_ = true, true
end

function CCNode:setScaleY(s)
    self.scaleY_ = s
    self.isTransformDirty_, self.isInverseDirty_ = true, true
end

function CCNode:setScale(s)
    self.scaleX_, self.scaleY_ = s, s
    self.isTransformDirty_, self.isInverseDirty_ = true, true
end

function CCNode:setPosition(...)
    self.position_:set(...)
    self.isTransformDirty_, self.isInverseDirty_ = true, true
end

function CCNode:setIgnoreAnchorForPosition(ignore)
    if ignore ~= self.ignoreAnchorForPosition_ then
        self.ignoreAnchorForPosition_ = ignore
        self.isTransformDirty_, self.isInverseDirty_ = true, true
    end    
end

function CCNode:setAnchor(...)
    local ap = self.anchor_
    ap:set(...)
        
    local cs, app = self.size_, self.anchorInPoints_
    app.x, app.y = cs.x * ap.x, cs.y * ap.y
    self.isTransformDirty_, self.isInverseDirty_ = true, true
end

function CCNode:setSize(...)
    local cs = self.size_
    cs:set(...)
        
    local ap, app = self.anchor_, self.anchorInPoints_
    app.x, app.y = cs.x * ap.x, cs.y * ap.y
    self.isTransformDirty_, self.isInverseDirty_ = true, true
end

---------------------
-- scene management
---------------------
function CCNode:draw()
end

function CCNode:onEnter()
    ccArrayForEach(self.children_, "onEnter")
    self:resumeSchedulerAndActions()
    
    self.isRunning_ = true
end

function CCNode:onEnterTransitionDidFinish()
    ccArrayForEach(self.children_, "onEnterTransitionDidFinish")
end

function CCNode:onExitTransitionDidStart()
    ccArrayForEach(self.children_, "onExitTransitionDidStart")
end

function CCNode:onExit()
    self:pauseSchedulerAndActions()
    self.isRunning_ = false
    
    ccArrayForEach(self.children_, "onExit")
end

---------------------
-- actions
---------------------
function CCNode:setActionManger()
    if self.actionManager_ ~= am then
        self:stopAllActions()
        self.actionManager_ = am
    end    
end

function CCNode:runAction(actionOrTable, tag)
    ccAssert(actionOrTable) -- you must provide a CCAction or a table readable by ccAction
    
    local action
    
    -- just checking to see if the actionOrTable has a class method
    -- is fast, but not as safe. if you pass a non-table/non-action
    -- object in, you will have problems
    --if ccInstanceOf(actionOrTable, Object) then
    if actionOrTable.class then
        -- this better be a CCAction, or you're gonna have problems...
        action = actionOrTable
    else
        -- this better be a table, or you're gonna have problems...
        action = ccAction(actionOrTable)
    end
    
    self.actionManager_:addAction(action, self, self.isRunning_ == false)
    return action    
end

function CCNode:stopAllActions()
    self.actionManager_:removeAllActionsFromTarget(self)
end

function CCNode:stopAction(action)
    self.actionManager_:removeAction(action)
end

function CCNode:stopActionByTag(tag)
    self.actionManager_:removeActionByTag(tag, self)
end

function CCNode:getActionByTag(tag)
    return self.actionManager_:getActionByTag(tag, self)
end

function CCNode:numberOfRunningActions()
    return self.actionManager_:numberOfRunningActionsInTarget(self)
end



---------------------
-- scheduler
---------------------
CCNode:synth{"scheduler", mode="r"}

function CCNode:schedule(selector, interval, times, delay)
    interval = interval or 0
    ccAssert(selector and (interval >= 0))
    return self.scheduler_:scheduleSelector(selector, self, interval, not self.isRunning_, times, delay)
end

function CCNode:unschedule(selector)
    if selector == nil then return end
    self.scheduler_:unscheduleSelector(selector, self)
end

function CCNode:unscheduleAllSelectors()
    self.scheduler_:unscheduleAllSelectorsForTarget(self)
end

function CCNode:resumeSchedulerAndActions()
    self.scheduler_:resumeTarget(self)
    self.actionManager_:resumeTarget(self)
end

function CCNode:pauseSchedulerAndActions()
    self.scheduler_:pauseTarget(self)    
    self.actionManager_:pauseTarget(self)    
end


----------------------
-- CCNodeRect
----------------------
CCNodeRect = CCClass(CCNode):include(CCRGBAMixin)

CCNodeRect:synth{ccc4, "strokeColor", mode="rc"}
CCNodeRect:synth{"strokeWidth"}
CCNodeRect:synth{"strokeEnabled"}

-- params: w, h, ccc3
function CCNodeRect:init(w, h, ...)
    CCNode.init(self)
    CCRGBAMixin.init(self, ...)
    self:setAnchor(.5, .5)    
    self:setSize(w,h)
    self.strokeWidth_ = 2
end

function CCNodeRect:strokeWidth()
    return self.strokeWidth_ or 2
end

function CCNodeRect:draw()
    local c = self.color_
    fill(c.r, c.g, c.b, self.opacity_)
    rectMode(CORNER)
    
    if self.strokeEnabled_ then
        stroke(self:strokeColor():unpack())
        strokeWidth(self:strokeWidth())
    else
        noStroke()        
    end

    local s = self.size_ 
    rect(0, 0, s.x, s.y)
end


----------------------
-- CCNodeEllipse
----------------------
CCNodeEllipse = CCClass(CCNode):include(CCRGBAMixin)

CCNodeEllipse:synth{ccc4, "strokeColor", mode="rc"}
CCNodeEllipse:synth{"strokeWidth"}
CCNodeEllipse:synth{"strokeEnabled"}


-- args: width, height, ccc3
-- args: diameter, ccc3
function CCNodeEllipse:init(...)
    CCNode.init(self)
    
    local w,h,c
    if #arg == 2 then
        w,h = arg[1], arg[1]
        c = arg[2]
    elseif #arg == 3 then
        w,h = arg[1], arg[2]
        c = arg[3]
    else
        ccAssert(false, "CCNodeEllipse:init -> invalid parameters specified)")
    end
    
    CCRGBAMixin.init(self, c)
    
    self:setAnchor(.5, .5)
    self:setSize(w,h)
    
    self.strokeWidth_ = 2
end

function CCNodeEllipse:draw()
    local c = self.color_
    fill(c.r, c.g, c.b, self.opacity_)    
    ellipseMode(CORNER)
    
    if self.strokeEnabled_ then
        stroke(self:strokeColor():unpack())
        strokeWidth(self:strokeWidth())
    else
        noStroke()        
    end    

    local s = self.size_ 
    ellipse(0, 0, s.x, s.y)
    
    -- debug draw sprite rect
    --[[ 
    noFill()
    strokeWidth(2)
    stroke(255,128,128)
    rect(0, 0, s.x, s.y)
    --]]    
end
