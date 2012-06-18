CCMenu = CCClass(CCLayer):include(CCRGBAMixin)

kCCMenuHandlerPriority = -128

CCMenu:synth{"isEnabled", set="setEnabled"}

local kCCMenuStateWaiting = 0
local kCCMenuStateTrackingTouch = 1

function CCMenu:init(...)
    CCLayer.init(self)
    CCRGBAMixin.init(self)
    
    self:setTouchEnabled(true)
    self:setEnabled(true)
    self:setAnchor(0.5, 0.5)
    
    local w, h = CCSharedDirector():winSize():unpack()
    self:setSize(w, h)
    self:setPosition(w/2, h/2)
    
    if #arg > 0 then
        local z = 0
        for i,item in ipairs(arg) do
            self:addChild(item, z)
            z = z + 1
        end
    end
    
    self.selectedItem_ = nil
    self.state_ = kCCMenuStateWaiting
end

function CCMenu:addChild(child, z, tag)
    ccAssert(child:instanceOf(CCMenuItem))
    CCLayer.addChild(self, child, z, tag)
end

function CCMenu:onExit()
    if self.state_ == kCCMenuStateTrackingTouch then
        self.selectedItem:unselected()
        self.state_ = kCCMenuStateWaiting
        self.selectedItem_ = nil
    end
    
    CCLayer.onExit(self)
end

function CCMenu:setHandlerPriority(newPri)
    CCSharedDirector():touchDispatcher():setPriority(self, newPri)
end

function CCMenu:registerWithTouchDispatcher()
    local d = CCSharedDirector():touchDispatcher()
    d:addTargetedDelegate(self, kCCMenuHandlerPriority, true)
end

function CCMenu:itemForTouch(touch)
    local p = ccVec2(touch.x, touch.y)
    p = CCSharedDirector():convertToGL(p)
    
    for i,item in ipairs(self.children_) do
        if item:visible() and item:isEnabled() then
            local pl = item:convertToNodeSpace(p)
            local r = item:rect()
            r.x, r.y = 0, 0
            
            if r:containsPoint(pl) then return item end
        end
    end
end

function CCMenu:ccTouchBegan(touch)
    if self.state_ ~= kCCMenuStateWaiting or not self:visible() or not self.isEnabled_ then
        return false
    end    
            
    local c = self.parent
    while c ~= nil do
        if not c:visible() then return false end
        c = c.parent
    end
    
    self.selectedItem_ = self:itemForTouch(touch)
    
    if self.selectedItem_ then
        self.selectedItem_:selected()
        self.state_ = kCCMenuStateTrackingTouch
        return true        
    end
    
    return false
end

function CCMenu:ccTouchMoved(touch)
    ccAssert(self.state_ == kCCMenuStateTrackingTouch)
    
    local currentItem = self:itemForTouch(touch)
    
    if currentItem ~= self.selectedItem_ then
        if self.selectedItem_ then self.selectedItem_:unselected() end
        self.selectedItem_ = currentItem
        if self.selectedItem_ then self.selectedItem_:selected() end
    end
end

function CCMenu:ccTouchEnded(touch)
    ccAssert(self.state_ == kCCMenuStateTrackingTouch)
    
    if self.selectedItem_ then 
        self.selectedItem_:unselected() 
        self.selectedItem_:activate()        
    end
    
    self.state_ = kCCMenuStateWaiting    
end

function CCMenu:setOpacity(o)
    CCCRGBAMixin.setOpacity(o)
    
    for i, item in ipairs(self.children_) do
        item:setOpacity(o)
    end
end

function CCMenu:setColor(c)
    CCCRGBAMixin.setColor(c)
    
    for i, item in ipairs(self.children_) do
        item:setColor(c)
    end    
end

function CCMenu:setColor4(c)
    CCCRGBAMixin.setColor4(c)
    
    for i, item in ipairs(self.children_) do
        item:setColor4(c)
    end        
end

------------------------
-- alignment
------------------------
local kDefaultPadding = 5

function CCMenu:alignItemsVertically(padding)
    padding = padding or kDefaultPadding
    local children = self.children_
    
    local height = -padding
    
    for i, item in ipairs(children) do
        height = height + item:size().y * item:scaleY() + padding
    end
    
    local y = height / 2
    
    for i, item in ipairs(children) do
        local size = item:size()
        local sy = item:scaleY()
        item:setPosition(0, y - size.y * sy / 2)
        y = y - size.y * sy + padding
    end
end

function CCMenu:alignItemsHorizontally(padding)
    padding = padding or kDefaultPadding
    local children = self.children_
    
    local width = -padding
    
    for i, item in ipairs(children) do
        width = width + item:size().x * item:scaleX() + padding
    end
    
    local x = -width / 2
    
    for i, item in ipairs(children) do
        local size = item:size()
        local sx = item:scaleX()
        item:setPosition(x + size.x * sx / 2, 0)
        x = x + size.x * sx + padding
    end
end

function CCMenu:alignItemsInRows(...)
    local rows = arg
    local children = self.children_
    
    local height = -5
    local row, rowHeight, occupied, rowCol = 1, 0, 0, nil
    
    for i,item in ipairs(children) do
        ccAssert(row <= #rows)
        
        rowCol = rows[row]
        ccAssert(rowCol)    -- can't have 0 items in a row
        
        rowHeight = math.max(rowHeight, item:size().y * item:scaleY())
        occupied = occupied + 1
        
        if occupied >= rowCol then
            height = height + rowHeight + 5
            
            occupied = 0
            rowHeight = 0
            row = row + 1
        end
    end
    
    ccAssert(occupied == 0)    -- too many rows/columns for available menu items
     
    local winSize = self:size()
    row, rowHeight, rowCol = 1, 0, 0
    local y, x, w = height/2, nil, nil
    
    for i, item in ipairs(children) do
        if rowCol == 0 then
            rowCol = rows[row]
            w = winSize.x / (1 + rowCol)
            x = w
        end

        local size = item:size()
        rowHeight = math.max(rowHeight, size.y * item:scaleY())
        item:setPosition(x-winSize.x/2, y-size.y/2)

        x = x + w
        occupied = occupied + 1
        
        if occupied >= rowCol  then
            y = y - rowHeight + 5
            occupied = 0
            rowCol = 0
            rowHeight = 0
            row = row + 1
        end
    end
end

function CCMenu:alignItemsInColumns(...)
    local columns = arg
    local children = self.children_
    
    local widths = {}
    local heights = {}
    
    local width, colHeight = -10, -5
    local col, colWidth, occupied, colRows = 1, 0, 0, nil
    
    for i, item in ipairs(children) do
        ccAssert(col <= #columns) -- too many items for the amount of rows/columns
            
        colRows = columns[col]
        ccAssert(colRows) -- can't have 0 rows
            
        local size = item:size()
        colWidth = math.max(colWidth, size.x * item:scaleX())
        colHeight = colHeight + size.y + 5
        occupied = occupied + 1
            
        if occupied >= colRows then
            ccArrayInsert(widths, colWidth)
            ccArrayInsert(heights, colHeight)
            width = width + colWidth + 10
            occupied = 0
            colWidth = 0     
            colHeight = -5
            col = col + 1
        end
    end
        
    ccAssert(occupied == 0) -- too many rows/columns for available items
        
    local winSize = self:size()
        
    col, colWidth, colRows = 1, 0, 0
    local x, y = -width / 2, nil
        
    for i, item in ipairs(children) do
        if colRows == 0 then
            colRows = columns[col]
            y = (heights[col] + winSize.y)/2
        end
        
        local size = item:size()
        colWidth = math.max(colWidth, size.x * item:scaleX())
        item:setPosition(x + widths[col] / 2, y - winSize.y/2)
        
        y = y - size.y + 10
        occupied = occupied + 1
            
        if occupied >= colRows then
            x = x + colWidth + 5
            occupied = 0
            colRows = 0
            colWidth = 0
            col = col + 1
        end
    end
end
