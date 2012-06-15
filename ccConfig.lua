--ccConfig

-- provide a stack traceback for failed assertionsasserts
local origAssert = assert
local function assert_(cond, ...)
    if not cond then print(debug.traceback()) end
    origAssert(cond, ...)    
end

local function printPair_(k, v)
    print("["..tostring(k).."]: "..tostring(v))
end

local function printArray_(array)
    for i,v in ipairs(array) do printPair_(i,v) end
end

local function printTable_(table)
    for k,v in pairs(table) do printPair_(k,v) end
end

ccAssert = assert_
ccPrint = print
ccPrintPair = printPair_
ccPrintArray = printArray_
ccPrintTable = printTable_
ccColor = color
ccVec2 = vec2


-- On retina devices, Codea will double the size of any sprites drawn with
-- the sprite() function that do not have an @2x version.
-- I discovered that passing the width and height values returned by
-- Codea's spriteSize() function will draw the sprite at the correct
-- size. As a result, sprites without a @2x version were drawn
-- at half size (the expected behavior without Codea's double sizing
-- support). This is the normal behavior for cocos2d.
--
-- Re-enabling Codea's scaling will cause any sprites with a @2x version 
-- to be double-sized on the retina iPad. So, you have a choice:
--    a) leave it disabled, and only use sprites with both a normal and an @2x
--       version, or they will be half-sized on retina displays (this is the
--       ideal option for users with and without retina displays)
--    b) enable it, and do not use any sprites with an @2x version, or they will
--       be double sized on retina displays. (your sprites will work the same on
--       all devices, but will be blurry on retina screens)

CC_ENABLE_CODEA_2X_MODE = false