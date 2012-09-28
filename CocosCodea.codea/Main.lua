-- Main

function setup()        
    local director = CCSharedDirector()
    director:showFPS(true)
end

function touched(touch)
    CCSharedDirector():touchDispatcher():touched(touch)
end

function draw()    
    background(0)
    CCSharedDirector():drawScene(DeltaTime)
end

