--ArrayUtil

kArrayAscending = 1
kArrayDescending = -1
kArraySame = 0

function arrayContainsObject(array, object)
    for _,v in ipairs(array) do
        if v == object then return true end
    end
    
    return false
end

function arrayIndexOfObject(array, object)
    for i, v in ipairs(array) do
        if v == object then return i end
    end
end  

function arrayGetIndex(array, obj)
    for i,v in ipairs(array) do
        if v == obj then return i end
    end
end

function arrayRemoveObject(array, obj)
    local idx = arrayGetIndex(array, obj)
    if idx then table.remove(array, idx) end
end

function arrayPerformSelectorOnObjects(array, selector)
    for i,v in ipairs(array) do v[selector](v) end    
end

function arrayPerformFunctionOnObjects(array, fn)
    for i,v in ipairs(array) do fn(v) end
end

function arrayRemoveAllObjects(array)
    while #array > 0 do table.remove(array, #array) end
end

function arrayShuffle(array)
    for i = #array, 1, -1 do
        local j = math.random(1, i)
        array[j], array[i] = array[i], array[j]
    end
end

function arrayLessThan(first, second)
    if first < second then return kArrayAscending
    elseif first > second then return kArrayDescending
    end
    
    return kArraySame
end

function arrayGreaterThan(first, second)
    return -arrayLessThan(first, second)
end

function arrayBubbleSort(array, comparator, property)
    ccAssert(array and comparator)
    local swapped = true
    local j = 0
    
    while swapped do
        swapped = false
        j = j + 1
        
        for i = 1, #array - j do
            local first, second = array[i], array[i+1]
            
            local p1, p2
            if property then
                p1, p2 = array[i][property], array[i+1][property]
            else
                p1, p2 = array[i], array[i+1]
            end            
            
            if comparator(p1, p2) ~= kArrayAscending then
                array[i], array[i+1] = array[i+1], array[i]
                swapped = true
            end
        end
    end
end