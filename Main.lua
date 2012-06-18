-- Main
function setup()
    --displayMode(FULLSCREEN)


    --[[
    -- this way is the shortest
    funct1{3, 100, 100, ease=CCEaseSineInOut, call="setVisible", false),
    
    -- but this way doesn't require special argument handling;
    -- the call is contained in a table. to pass arguments and not have to
    -- us an arg consumption method, we have to contain the args in a table
    -- anyway, so why not just include the call in there as well
    funct1{3, 100, 100, ease=CCEaseSineInOut, call={"setVisible", false}},
    funct1{3, 100, 100, ease=CCEaseSineInOut, call={node, "setVisible", false}}    
    funct1{3, 100, 100, ease=CCEaseSineInOut, call={function(t) t:setVisible(false) end}},
    funct1{3, 100, 100, ease=CCEaseSineInOut, call={function(t,v) t:setVisible(v) end, false}},  
    
    -- in the last one, if call is just a function with no args, we can allow the shortcut
    funct1{3, 100, 100, ease=CCEaseSineInOut, call=function(t) t:setVisible(false) end}

    -- compare to current CocosCodea and tween.lua
    ccAction{CCEaseSineInOut(CCMove(3, 100, 100)), CCCallT("setVisible"), false},
    
    CCMoveBy{ 3, 100, 100, ease=CCEaseSineInOut, loop=true,
        call={"setVisible", false} 
    },
    
    CCTween{3, ease=CCEaseSineInOut,
        {position = vec2(100, 100), color = ccc3(255)},
        call={"setVisible", false}
    }

    CCTween{3, "color", fin=ccc3(255), ease=CCEaseSineInOut}
    
    tween(3, node.position_, {x=100, y=100}, "outInSine", 
        function() node:setVisible(false) end
    )
    --]]
    
    --[[
    
        node:runAction {
            CCDelay{5}, 
            CCMoveTo{3, 100, 30, ease=CCEaseSineInOut, call={"setVisible", false}},
            CCDelay{5, call={"setVisible", true}},
            CCRotateBy{5, 720},
        }
    --]]
    
    
    
    
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