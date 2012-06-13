--CCNode
CCNode = CCClass()

ccProp{CCNode, "visible"}
ccProp{CCNode, "rotation", mode = "r"}
ccProp{CCNode, "scaleX", mode = "r"}
ccProp{CCNode, "scaleY", mode = "r"}
ccProp{CCNode, "scale", "scaleX_", mode = "r"}
ccProp{CCNode, "ignoreAnchorPointForPosition", mode = "r"}
ccPropVec2{CCNode, "position", mode = "r"}
ccPropVec2{CCNode, "anchorPoint", mode = "r"}
ccPropVec2{CCNode, "contentSize", mode = "r"}

function CCNode:init()
    self.position_ = vec2(0,0)
    self.anchorPoint_ = vec2(0,0)
    self.anchorPointInPoints_ = vec2(0,0)
    self.ignoreAnchorPointForPosition_ = false
    self.contentSize_ = vec2(0,0)
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
    
    self.tag = -1    
    self.children = {}
    
    local dir = CCSharedDirector()
    self.actionManager_ = dir:actionManager()
    self.scheduler_ = dir:scheduler()
    --self.touchDispatcher_ = dir:touchDispatcher()
end

local function insertChild(node, child, z)
    local children = node.children
    local last = children[#children]
    
    if last == nil or last.zOrder <= z then
        table.insert(children, child)
    else
        --ccPrint("Last: "..last.zOrder.."    new: "..z)        
        for i,v in ipairs(children) do
            if last.zOrder > z then
                table.insert(children, i, child)
                break
            end
        end
    end
    
    child.zOrder = z
end

function CCNode:addChild(child, z, tag)
    insertChild(self, child, z or 0)
    if tag ~= nil then child.tag = tag end
    child.parent = self
end

function CCNode:getChildByTag(tag)
    for i,v in ipairs(self.children) do
        if v.tag == tag then return v end
    end
    
    return nil
end

function CCNode:reorderChild(child, z)
    local idx = getChildIndex(self, child)
    
    if idx then        
        local c = self.children[idx]
        table.remove(self.children, idx)
        insertChild(self, child, z)
    end
end

function CCNode:detachChild(child, cleanup)
    if self.isRunning_ then
        child:onExitTransitionDidStart()
        child:onExit()
    end
    
    if cleanup then child:cleanup() end
        
    child.parent = nil
    arrayRemoveObject(self.children, child)
end

function CCNode:removeChild(child, cleanup)
    if not child then return end

    --default cleanup = true
    if cleanup == nil then cleanup = true end
    
    if arrayContainsObject(self.children, child) then
        self:detachChild(child, cleanup)
    end
end

function CCNode:removeChildByTag(tag, cleanup)
    child = self:getChildByTag(tag)
    
    if child then
        -- default cleanup = true
        if cleanup == nil then cleanup = true end
        self:removeChild(child, cleanup)
    end
end

function CCNode:removeAllChildren(cleanup_)
    -- default cleanup to true
    if cleanup_ == nil then cleanup_ = true end
    
    for i, child in ipairs(self.children) do
        if self.isRunning_ then
            child:onExitTransitionDidStart()
            child:onExit()
        end
        
        if cleanup_ then child:cleanup() end
        child.parent = nil
    end
    
    arrayRemoveAllObjects(self.children)
end

function CCNode:removeFromParent(cleanup_)
    if self.parent then
        -- default cleanup = true
        if cleanup_ == nil then cleanup_ = true end
        self.parent:removeChild(self, cleanup_)
    end
end

function CCNode:cleanup()
    --ccPrint("cleanup: " .. tostring(self))
    self:stopAllActions()
    self:unscheduleAllSelectors()
    arrayPerformSelectorOnObjects(self.children, "cleanup")
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
    
    local children = self.children      
    
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
        local pos, app = self.position_, self.anchorPointInPoints_
        local x, y, sx, sy = pos.x, pos.y, self.scaleX_, self.scaleY_
        local c, s, angle = 1, 0, self.rotation_
        
        if angle ~= 0 then
            local rad = -math.rad(angle)
            c, s = math.cos(rad), math.sin(rad)
        end
        
        if self.ignoreAnchorPointForPosition_ then
            x = x + app.x
            y = y + app.y
        end        
        
        if app ~= vec2(0, 0) then
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
    
    local p = self.parent    
    while p do
        t = t * p:nodeToParentTransform()
        p = p.parent 
    end
    
    return t
end

function CCNode:worldToNodeTransform()
    return self:nodeToWorldTransform():inverse()
end

local function affineTransform(pt, m)
    return vec2(m[1]*pt.x+m[5]*pt.y + m[13], m[2]*pt.x+m[6]*pt.y+m[14])
end

function CCNode:convertToNodeSpace(worldPt)
    return affineTransform(worldPt, self:worldToNodeTransform())
end

function CCNode:convertToWorldSpace(nodePt)
    return affineTransform(nodePt, self:nodeToWorldTransform())
end

function CCNode:convertToNodeSpaceAR(worldPt)
    return self:convertToNodeSpace(worldPt) - self.anchorPointInPoints_
end

function CCNode:convertToWorldSpaceAR(nodePt)
    return self:convertToWorldSpace(nodePt + self.anchorPointInPoints_)
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
    local pos = self.position_
    pos.x, pos.y = ccVec2VA(...)
    self.isTransformDirty_, self.isInverseDirty_ = true, true
end

function CCNode:setIgnoreAnchorPointForPosition(ignore)
    if ignore ~= self.ignoreAnchorPointForPosition_ then
        self.ignoreAnchorPointForPosition_ = ignore
        self.isTransformDirty_, self.isInverseDirty_ = true, true
    end    
end

function CCNode:setAnchorPoint(...)
    local ap = self.anchorPoint_
    ap.x, ap.y = ccVec2VA(...)
        
    local cs, app = self.contentSize_, self.anchorPointInPoints_
    app.x, app.y = cs.x * ap.x, cs.y * ap.y
    self.isTransformDirty_, self.isInverseDirty_ = true, true
end


function CCNode:setContentSize(...)
    local cs = self.contentSize_
    cs.x, cs.y = ccVec2VA(...)
        
    local ap, app = self.anchorPoint_, self.anchorPointInPoints_
    app.x, app.y = cs.x * ap.x, cs.y * ap.y
    self.isTransformDirty_, self.isInverseDirty_ = true, true
end

---------------------
-- scene management
---------------------
function CCNode:draw()
end

function CCNode:onEnter()
    arrayPerformSelectorOnObjects(self.children, "onEnter")
    self:resumeSchedulerAndActions()
    
    self.isRunning_ = true
end

function CCNode:onEnterTransitionDidFinish()
    arrayPerformSelectorOnObjects(self.children, "onEnterTransitionDidFinish")
end

function CCNode:onExitTransitionDidStart()
    arrayPerformSelectorOnObjects(self.children, "onExitTransitionDidStart")
end

function CCNode:onExit()
    self:pauseSchedulerAndActions()
    self.isRunning_ = false
    
    arrayPerformSelectorOnObjects(self.children, "onExit")
end

---------------------
-- actions
---------------------
function CCNode:actionManager(am)
    if am == nil then
        return self.actionManager_
    else
        if self.actionManager_ ~= am then
            self:stopAllActions()
            self.actionManager_ = am
        end
    end
end

function CCNode:runAction(action)
    return self.actionManager_:addAction(action, self, self.isRunning_ == false)
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
ccProp{CCNode, "scheduler", mode="r"}

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

function CCNodeRect:init(w, h, ...)
    CCNode.init(self)
    CCRGBAMixin.init(self, ...)
    self:setContentSize(w,h)
end

function CCNodeRect:draw()
    local c = self.color_    
    fill(c.r, c.g, c.b, c.a)    
    rectMode(CORNER)
    noStroke()

    local s = self.contentSize_ 
    rect(0, 0, s.x, s.y)
end