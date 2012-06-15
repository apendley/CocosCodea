CocosCodea: Cocos2d ported to Lua(for Codea)
=

A special note: On retina iPads, Codea automatically double-sizes any sprites with an image that don't have an @2x version. CocosCodea undoes this double sizing by default, so non-retina sprites will draw at half size on retina devices. in ccConfig.lua, you can re-enable Codea's scaling by setting CC_ENABLE_CODEA_2X_MODE to true, but then any images that do have an  @2x version will be drawn at double size on retina devices. So, if you want everything to work the same on all devices, you either need to leave CC_ENABLE_CODEA_2X_MODE disabled, and only use art with @2x versions, or enable CC_ENABLE_CODEA_2X_MODE, and only use art without @2x versions.

What's here:
-
**General:** 

* hierarchical render node graph
* the famous cocos2d action system
* versatile scheduler
* prioritized touch dispatching with "touch swallowing"

**System:**
* CCDirector
* CCTouchDispatcher (targeted touch delegates only)
* CCScheduler (selector scheduling only)
* CCActionManager

**Nodes:**
* CCNode
* CCNodeRect (new)
* CCNodeEllipse (new)
* CCScene
* CCLayer
* CCSprite
* CCLabelTTF 
* CCMenu
* CCMenuItemSprite
* CCMenuItemLabel
* CCMenuItemFont
* CCMenuItemToggle

**Scene Transitions:**
* CCTransitionFade
* CCTransitionRotoZoom
* CCTransitionJumpZoom
* CCTransitionMoveInL/T/R/B
* CCTransitionSlideInL/T/R/B
* CCTransitionShrinkGrow

**Actions:**
* CCFunc (CCCallBlock in cocos2d-iphone)
* CCFuncT (CCCallBlockN in cocos2d-iphone)
* CCMethod (CCCallFunc in cocos2d-iphone)
* CCMethodT (CCCallFuncN in cocos2d-iphone)
* CCCallTarget (new)
* CCShow
* CCHide
* CCToggleVisibility
* CCPlace
* CCPrint (new)
* CCPrintT (new)
* CCSequence
* CCSpawn
* CCRepeat
* CCRepeatForever
* CCSpeed
* CCDelayTime
* CCMoveTo/CCMoveBy
* CCRotateTo/CCRotateBy
* CCScaleTo/CCScaleBy
* CCJumpTo/CCJumpBy
* CCBlink
* CCTintTo/CCTintBy
* CCFadeIn/CCFadeOut/CCFadeTo
* CCTween
* CCEaseIn/CCEaseOut
* CCEaseExponentialIn/CCEaseExponentialOut/CCEaseExponentialInOut
* CCEaseSineIn/CCEaseSineOut/CCEaseSineInOut

**Other:**
* CocosCodea uses customized version of a class system called MiddleClass by Enrique García Cota
* synthesize get/set methods for class properties
* create reusable interfaces with CCMixin
	
	
What's not here (yet):
-
**General:**
* batched sprites
* animation system
* Accelerometer handling
* non-targeted touch delegates
* prioritized scheduling
* bitmapped fonts
* tilemaps
* particles and effects
* setting UV coordinates on CCSprites (current Codea limitation)

**Nodes:**
* CCAtlasNode
* CCLabelBMFont
* CCSpriteBatchNode
* CCMenuItemAtlasFont
* CCParallaxNode
* CCTMX*
* CCMotionStreak
* CCProgressTimer
* CCRenderTexture

**Transitions:**
* CCTransitionPageTurn
* CCTransitionRadial
* CCTransitionFlipX
* CCTransitionFlipY
* CCTransitionFlipAngular
* CCTransitionZoomFlipX
* CCTransitionZoomFlipY
* CCTransitionZoomFlipAngular
* CCTransitionCrossFade
* CCTransitionTurnOffTiles
* CCTransitionSplitCols
* CCTransitionSplitRows
* CCTransitionFadeTR
* CCTransitionFadeBL
* CCTransitionFadeUp
* CCTransitionFadeDown


**Actions:**
* CCActionCamera/CCOrbitCamera
* CCFollow
* CCSkewBy/CCSkewTo
* CCBezierTo/CCBezierBy
* CCReverseTime
* CCAnimate
* CCEaseElastic*
* CCEaseBounce*
* CCActionTiledGrid based actions
* CCActionGrid3D based actions
* CCActionGrid based actions
* CCActionPageTurn3D
* CCActionProgressTimer
* CCCatmullRomTo/CCCatmullRomBy

**Other:**
* CCSpriteFrame
* CCAnimation
* CCGrid