CocosCodea: Cocos2d ported to Lua(for Codea)
=

Codea is a wonderful iPad app that allows game creation and rapid prototyping using the Lua programming language. Cocos2d-iphone is fully featured game "engine" for iOS. Often, while playing with Codea, I have wished for some of cocos2d's more advanced features, like actions and scheduling. So, I've decided to port as much of cocos2d to Codea as I can. It's not necessarily a straight port; I'm taking advantage of Codea and Lua features as much as I can to make it the best experience possible on the iPad, including shortening names wherever possible to reduce typing, allowing function argument "overloading" using Lua's flexible calling system where helpful, using Codea's rendering system, implementing a way to synthesize get/set methods for class properties, etc. It's not all here yet. There is still tons to do, but I have tried to get the core in so that CocosCodea can hopefully start being useful to somebody besides me.

Currently Codea has some limitations that make it difficult or impossible to implement some cocos2d functionality, such as specifying (s,t) and (u,v) coordinates for indivially drawn sprites (for CCSprite's textureRect) and lack of file I/O for multi-file assets (sprite sheets, tile maps, particle systems). When/if those limitations are addressed, or as I discover workarounds, I will update CocosCodea as necessary.

At the moment nothing is optimized, as I've been working feverishly to get the core in, so CocosCodea is not as fast as it probably could be.  Other than this readme, there is currently no documentation. There are currently sparse examples of how to do things for the cocos2d/Codea uninitiated. Overloaded function arguments are sparsly documented. I will work to fix these things as I go. Also, this code is incredibly volatile. Right now it's here just for preview and experimental purposes, and I reserve the right to make breaking changes. I will tag stable branches soon, and keep a changelog, when the pace slows down a bit.

If you have a suggestion for an optimization or CocosCodea in general, or if you'd like to contribute, just let me know.

**A special note:** On retina iPads, Codea automatically double-sizes any sprites with an image that don't
 have an @2x version. CocosCodea undoes this double sizing, so non-retina sprites will draw 
 at half size on retina devices (this is actually the standard for iOS). If you want to use non-retina sprites, for now you
 must scale them manually by ContentScaleFactor so that they display correctly on retina iPads. Or, use only sprites with retina versions.
 I'm trying to find a way to enable a "Double size mode" flag that will reinstate the Codea scaling behavior, but so far have not been successful.


What's here:
-
**General:** 

* hierarchical render node graph
* the famous cocos2d action system
* versatile scheduler
* prioritized touch dispatching with "touch swallowing"
* batched sprites (no TexturePacker/Zwoptex support yet, but sprites can now be batch drawn and have their texture coordinates set)

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
* CCSpriteBatchNode
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
* CCCallT (new)
* CCShow
* CCHide
* CCToggleVisibility
* CCPlace
* CCPrint (new)
* CCPrintT (new)
* CCSequence
* CCSpawn
* CCRepeat
* CCLoop (CCRepeatForever in cocos2d-iphone)
* CCSpeed
* CCDelay (CCDelayTime in cocos2d-iphone)
* CCMoveTo/CCMoveBy
* CCRotateTo/CCRotateBy
* CCScaleTo/CCScaleBy
* CCJumpTo/CCJumpBy
* CCBlink
* CCTintTo/CCTintBy
* CCFadeIn/CCFadeOut/CCFadeTo
* CCTween
* CCEaseIn/CCEaseOut
* CCEaseExponentIn/CCEaseExponentOut/CCEaseExponentInOut (CCEaseExponential* in cocos2d-iphone)
* CCEaseSineIn/CCEaseSineOut/CCEaseSineInOut

**Other:**
* CocosCodea uses customized version of a class system called MiddleClass by Enrique García Cota
* create reusable interfaces with CCMixin
* synthesize get/set methods for class properties
	
	
What's not here (yet):
-

**General:**
* animation system
* Accelerometer handling
* non-targeted touch delegates
* prioritized scheduling
* bitmapped fonts
* tilemaps
* particles and effects
* setting UV coordinates on CCSprites (current Codea limitation, to be addressed in a future update)

**Nodes:**
* CCAtlasNode
* CCLabelBMFont
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
* CCFlipX
* CCFlipY
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