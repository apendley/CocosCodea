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
ccVec2 = vec2


-- patch data types with copy, unpack, and set methods
CC_PATCH_COLOR = true
CC_PATCH_VEC = true

if CC_PATCH_COLOR then
    local mt = getmetatable(color())
    mt.unpack = function(c) return c.r, c.g, c.b, c.a end
    mt.copy = function(c) return color(c.r, c.g, c.b, c.a) end
    mt.set = function(c, ...) c.r, c.g, c.b, c.a = ccc4VA(...) end
end

if CC_PATCH_VEC then
    local mt = getmetatable(vec2())
    mt.copy = function(v) return vec2(v.x, v.y) end    
    mt.unpack = function(v) return v.x, v.y end
    mt.set = function(v, ...) v.x, v.y = ccVec2VA(...) end
end