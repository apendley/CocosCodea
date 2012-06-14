-- Main

function setup()
    displayMode(FULLSCREEN)
    
    local director = CCSharedDirector()
    director:showFPS(true)
    director:runWithScene(MyRetinaTest:scene())
end

function touched(touch)
    CCSharedDirector():touchDispatcher():touched(touch)
end

function draw()    
    background(0)
    CCSharedDirector():drawScene(DeltaTime)
end