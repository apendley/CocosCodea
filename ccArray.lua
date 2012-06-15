--ccArray

ccOrderAscending = 1
ccOrderDescending = -1
ccOrderSame = 0

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

function ccArrayRemove(array, obj)
    local idx = ccArrayIndexOf(array, obj)
    if idx then table.remove(array, idx) end
end

function ccArrayForEach(array, fnOrSelector)
	if type(fnOrSelector) == "function" then
	    for i,v in ipairs(array) do fnOrSelector(v) end	
	else
	    for i,v in ipairs(array) do v[fnOrSelector](v) end
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


ccSort = {}

ccSort.lt = function(a,b) return (a<b) end
ccSort.gt = function(a,b) return (a>b) end
ccSort.ltKey = function(key) return function(a, b) return (a[key] < b[key]) end end
ccSort.gtKey = function(key) return function(a, b) return (a[key] > b[key]) end end

function ccArraySort(array, comparator)
	return table.sort(array, comparator)
end


function ccCompareLT(first, second)
	if first < second then return ccOrderAscending
	elseif first > second then return ccOrderDescending
	end
		
	return ccOrderSame
end


function ccCompareGT(first, second)
	if first > second then return ccOrderAscending
	elseif first < second then return ccOrderDescending
	end
	
	return ccOrderSame	
end

-- a simple bubble sort
function ccArrayBubbleSort(array, comparator, keyOrNil)
    ccAssert(array and comparator)

    local swapped = true
    local j = 0
    
    while swapped do
        swapped = false
        j = j + 1
        
		local p1, p2, first, second
        for i = 1, #array - j do
			first, second = array[i], array[i+1]
            
            if keyOrNil then
                p1, p2 = array[i][keyOrNil], array[i+1][keyOrNil]
            else
                p1, p2 = array[i], array[i+1]
            end            
            
            if comparator(p1, p2) == ccOrderDescending then
                array[i], array[i+1] = array[i+1], array[i]
                swapped = true
            end
        end
    end
end

function ccArrayCopy(array)
    local t = {}
    for i,v in ipairs(array) do t[i] = v end
    return t
end