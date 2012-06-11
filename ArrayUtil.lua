
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

function arrayRemoveAllObjects(array)
    while #array > 0 do table.remove(array, #array) end
end
