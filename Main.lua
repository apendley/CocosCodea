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