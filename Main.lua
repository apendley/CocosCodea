-- Main
function setup()
    --displayMode(FULLSCREEN)

    -- test pulling down a file from my public dropbox folder
    local function getComplete(data, status, headers)
        print(data)
    end
    --http.get("https://dl.dropbox.com/u/8445683/sprites.plist", getComplete)
    
    
    local director = CCSharedDirector()
    director:showFPS(true)
    director:runWithScene(BatchNodeTest:scene())
    --director:runWithScene(MyRetinaTest:scene())
    --director:runWithScene(MyLayer:scene())
end

function touched(touch)
    CCSharedDirector():touchDispatcher():touched(touch)
end

function draw()    
    background(0)
    CCSharedDirector():drawScene(DeltaTime)
    
    --[[
    fill(0, 255, 0)
    strokeWidth(5)
    pointSize(20)
    point(WIDTH/2, HEIGHT/2)
    --]]
end