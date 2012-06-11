function ccUnpackColor(c) return c.r, c.g, c.b end
function ccUnpackColorRaw(c) return c.r, c.g, c.b, c.a end
function ccCopyColor(c) local r,g,b = ccUnpackColor(c) return color(r, g, b, 255) end
function ccCopyColorRaw(c) return color(ccUnpackColorRaw(c)) end

FLT_EPSILON = FLT_EPSILON or 0.00000011920929
