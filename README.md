CocosCodea: Cocos2d ported to Lua(for Codea)

What's here:
-----------------------------------------------
General:
	* hierarchical render node graph
	* the famous cocos2d action system
	* versatile scheduler
	* prioritized touch dispatching with "touch swallowing"

system:
	CCDirector
	CCTouchDispatcher (targeted touch delegates only)
	CCScheduler (selector scheduling only)
	CCActionManager

Nodes:
	CCNode
	CCNodeRect (new)
	CCNodeEllipse (new)
	CCScene
	CCLayer
	CCSprite
	CCLabelTTF 
	CCMenu
	CCMenuItemSprite
	CCMenuItemLabel
	CCMenuItemFont
	CCMenuItemToggle

Scene Transitions:
	CCTransitionFade
	CCTransitionRotoZoom
	CCTransitionJumpZoom
	CCTransitionMoveInL/T/R/B
	CCTransitionSlideInL/T/R/B
	CCTransitionShrinkGrow

Actions
	CCFunc (CCCallBlock in cocos2d-iphone)
	CCFuncT (CCCallBlockN in cocos2d-iphone)
	CCMethod (CCCallFunc in cocos2d-iphone)
	CCMethodT (CCCallFuncN in cocos2d-iphone)
	CCCallTarget (new)
	CCShow
	CCHide
	CCToggleVisibility
	CCPlace
	CCPrint (new)
	CCPrintT (new)
	CCSequence
	CCSpawn
	CCRepeat
	CCRepeatForever
	CCSpeed
	CCDelayTime
	CCMoveTo/CCMoveBy
	CCRotateTo/CCRotateBy
	CCScaleTo/CCScaleBy
	CCJumpTo/CCJumpBy
	CCBlink
	CCTintTo/CCTintBy
	CCFadeIn/CCFadeOut/CCFadeTo
	CCTween
	CCEaseIn/CCEaseOut
	CCEaseExponentialIn/CCEaseExponentialOut/CCEaseExponentialInOut
	CCEaseSineIn/CCEaseSineOut/CCEaseSineInOut

other:
	* CCClass - a customized version of a class system called MiddleClass by Enrique García Cota
	* synthesize get/set methods for a class property
	* ccc3/ccc4 color functions
	* ccRect type (partially implemented)
	* create reusable interfaces with CCMixin
	
	
What's not here (yet):
-----------------------------------------------
general:
	* batched sprites
	* animation system
	* Accelerometer handling
	* non-targeted touch delegates
	* prioritized scheduling
	* bitmapped fonts
	* tilemaps
	* particles and effects
	* setting UV coordinates on CCSprites (current Codea limitation)

Nodes:
	CCAtlasNode
	CCLabelBMFont
	CCSpriteBatchNode
	CCMenuItemAtlasFont
	CCParallaxNode
	CCTMX*
	CCMotionStreak
	CCProgressTimer
	CCRenderTexture

Transitions:
	CCTransitionPageTurn
	CCTransitionRadial
	CCTransitionFlipX
	CCTransitionFlipY
	CCTransitionFlipAngular
	CCTransitionZoomFlipX
	CCTransitionZoomFlipY
	CCTransitionZoomFlipAngular
	CCTransitionCrossFade
	CCTransitionTurnOffTiles
	CCTransitionSplitCols
	CCTransitionSplitRows
	CCTransitionFadeTR
	CCTransitionFadeBL
	CCTransitionFadeUp
	CCTransitionFadeDown
	CCSkewBy/CCSkewTo
	CCBezierTo/CCBezierBy
	CCReverseTime
	CCAnimate
	CCEaseElastic*
	CCEaseBounce*
	CCActionTiledGrid based actions
	CCActionGrid3D based actions
	CCActionGrid based actions
	CCActionPageTurn3D
	CCActionProgressTimer


Actions:
	CCActionCamera/CCOrbitCamera
	CCFollow

other:
	CCSpriteFrame
	CCAnimation
	CCGrid