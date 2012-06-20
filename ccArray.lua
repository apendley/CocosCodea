--ccArray

ccArrayInsert = table.insert
ccArrayRemove = table.remove

function ccArrayCopy(array)
	return { unpack(array) }
end

function ccArrayContains(array, object)
    for _,v in ipairs(array) do
        if v == object then return true end
    end
    
    return false
end

function ccArrayIndexOf(array, object)
    for i, v in ipairs(array) do
        if v == object then return i end
    end
end  

function ccArrayRemoveObject(array, obj)
    local idx = ccArrayIndexOf(array, obj)
    if idx then table.remove(array, idx) end
end

function ccArrayForEach(array, fnOrSelector, ...)
    if type(fnOrSelector) == "function" then
        for i,v in ipairs(array) do fnOrSelector(v, ...) end    
    else
        for i,v in ipairs(array) do v[fnOrSelector](v, ...) end
    end
end

function ccArrayClear(array)
    while #array > 0 do table.remove(array, #array) end
end

function ccArrayShuffle(array)
    for i = #array, 1, -1 do
        local j = math.random(1, i)
        array[j], array[i] = array[i], array[j]
    end
end

-- array sorting
ccCompareLT = function(a,b) return (a<b) end
ccCompareGT = function(a,b) return (b>a) end 
ccCompareKeyLT = function(key) return function(a, b) return (a[key] < b[key]) end end
ccCompareKeyLT = function(key) return function(a, b) return (a[key] > b[key]) end end
ccArraySort = table.sort

-- a simple bubble sort
function ccArrayBubbleSort(array, comparator)
    ccAssert(array)
    comparator = comparator or ccCompare.lt

    local swapped = true
    local j = 0
    
    while swapped do
        swapped = false
        j = j + 1
        
        local p1, p2, first, second
        for i = 1, #array - j do
            first, second = array[i], array[i+1]
            
            if keyOrNil then
                p1, p2 = first[keyOrNil], second[keyOrNil]
            else
                p1, p2 = first, second
            end            
            
            if not comparator(p1, p2) then
                array[i], array[i+1] = second, first
                swapped = true
            end
        end
    end
end