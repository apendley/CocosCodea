-- Main

-- TODO
-- * add prioritized updates to CCScheduler and CCNode classes
-- * use suffixed underscore to indicate "private" class variables
-- * test child removal and cleanup
-- * allow CCSprite to use an image()
-- * labels
-- * implements SpriteBatchNodes
-- * lazily create children table
-- * do fast children sort in visit(?)
-- * implmement transitions
-- * implement skew
-- * CCEaseElastic(in/out/inout), CCBounce(in/out/inout), CCEaseBack(in/out/inout)
-- * skewBy, skewTo, JumpBy, JumpTo, BezierBy, BezierTo
-- * ReverseTime, Animate, TargetedAction
-- * CCActionCatmullRom

-- * write alternative version of sprite() in backend, and try to get TLL to use it
-- * when codea allows (s, t, u, v) to be specfied for a sprite
    -- * add textureRect to CCSprite
    -- * add flipX and flipY to CCSprite

-- provide a stack traceback for failed assertionsasserts
local oldAssert = assert
function assert(cond, ...)
    if not cond then print(debug.traceback()) end
    oldAssert(cond, ...)    
end

function setup()
    --displayMode(FULLSCREEN)
    
    -- create director singleton
    local director = CCDirector:instance()
    director:runWithScene(MyLayer:scene())
      
    
    fps = FPSCounter()
        
    local startFrames = 30
    startWait = startFrames/60
    waitCounter = startWait
end

function draw()
    background(128, 128, 128, 0)
    
    waitCounter = waitCounter - DeltaTime
    if waitCounter > 0 then 
        fill(0)
        fontSize(40)
        local str = string.format("Please Wait: %.02f%%", (startWait - waitCounter) / startWait)
        text(str, WIDTH/2, HEIGHT/2)
        fps:draw()        
        return
    end
    
    CCDirector:instance():drawScene()

    fps:draw()
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
