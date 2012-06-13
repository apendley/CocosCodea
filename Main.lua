-- Main

function setup()
    --displayMode(FULLSCREEN)        
    local director = CCSharedDirector()
    director:showFPS(true)
    director:runWithScene(MyLayer:scene())
end

function touched(touch)
    CCSharedDirector():touchDispatcher():touched(touch)
end

function draw()    
    background(128, 128, 128, 0)
    CCSharedDirector():drawScene(DeltaTime)
end



--[[
function drawManySprites(num)
    fill(128, 128, 128)
    rect(0, 0, WIDTH, HEIGHT)
    
    local x = WIDTH/2
    local y = HEIGHT/2
    local w,h = spriteSize("Playing Cards:A_S")
    
    for i = 1, num do
        sprite("Playing Cards:A_S", x, y)
        x = x - w/2
        y = y - w/2
    end    
end
--]]
