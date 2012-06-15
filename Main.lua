-- Main

function setup()
    --displayMode(FULLSCREEN)

    local director = CCSharedDirector()
    director:showFPS(true)
    director:runWithScene(MyLayer3:scene())
end

function touched(touch)
    CCSharedDirector():touchDispatcher():touched(touch)
end

function draw()    
    background(0)
    CCSharedDirector():drawScene(DeltaTime)
    
    --[[
    fill(255)
    textSize(20)
    text(DeltaTime, WIDTH/2, HEIGHT/2)
    --]]
    
    --[[
    fill(0, 255, 0)
    strokeWidth(5)
    pointSize(20)
    point(WIDTH/2, HEIGHT/2)
    --]]
end