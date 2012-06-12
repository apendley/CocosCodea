-- Main

-- TODO
-- * CCMenuItemToggle
-- * add CCMenu alignment functions
-- * alias color constructor as CCColor, and make all cocos code use CCColor
-- * add prioritized updates to CCScheduler and CCNode classes
-- * test child removal and cleanup
-- * implements batched sprites (using mesh)
-- * implement bitmapped fonts
-- * implement tilemaps (using mesh)-- * labels
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

function setup()
    --displayMode(FULLSCREEN)        
    
    -- create director singleton
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
