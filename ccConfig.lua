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

ccFLT_EPSILON = 0.00000011920929