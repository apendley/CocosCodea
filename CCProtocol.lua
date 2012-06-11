--CCRGBAProtocol
CCRGBAProtocol = {}
--CCRGBAProtocol = { color_ = color(255, 255, 255, 255) }

function CCRGBAProtocol.init(inst)
    inst.color_ = inst.color_ or color(255, 255, 255, 255)
end
    
function CCRGBAProtocol:setColor(...)
    local mine = self.color_
    
    if #arg >= 3 then
        mine.r, mine.g, mine.b = unpack(arg)
    elseif #arg == 1 then
        mine.r, mine.g, mine.b = ccUnpackColor(arg[1])
    else
        assert(false, "setColor usage: setColor(r, g, b) or setColor(color)")
    end
end

function CCRGBAProtocol:color()
    return ccCopyColor(self.color_)
end

function CCRGBAProtocol:setOpacity(o)
    self.color_.a = o
end

function CCRGBAProtocol:opacity()
    return self.color_.a
end

function CCRGBAProtocol:setColorRaw(...)
    local mine = self.color_
    
    if #arg >= 3 then
        mine.r, mine.g, mine.b, mine.a = unpack(arg)
        mine.a = mine.a ~= nil and mine.a or 255
    elseif #arg == 1 then
        mine.r, mine.g, mine.b, mine.a = ccUnpackColorRaw(arg[1])
    else
        assert(false, "setColor usage: setColorRaw(r, g, b, [a]) or setColorRaw(color)")
    end
end

function CCRGBAProtocol:colorRaw()
    return ccCopyColorRaw(self.color_)
end