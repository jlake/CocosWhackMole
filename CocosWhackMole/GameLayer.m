//
//  GameLayer.m
//  CocosWhackMole
//
//  Created by 欧 on 11/05/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "SimpleAudioEngine.h"

int const LEVEL1_MOLE_COUNT = 50;

@implementation GameLayer

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
    
	return scene;
}


- (id)init
{
	if((self=[super init])) {
        hdFlg = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        winSize = [CCDirector sharedDirector].winSize;

        //NSString *bgSheet = hdFlg ? @"background-hd.pvr.ccz" : @"background.pvr.ccz";
        NSString *bgPlist = hdFlg ? @"background-hd.plist" : @"background.plist";
        //NSString *fgSheet = hdFlg ? @"foreground-hd.pvr.ccz" : @"foreground.pvr.ccz";
        NSString *fgPlist = hdFlg ? @"foreground-hd.plist" : @"foreground.plist";
        NSString *sSheet = hdFlg ? @"sprites-hd.pvr.ccz" : @"sprites.pvr.ccz";
        NSString *sPlist = hdFlg ? @"sprites-hd.plist" : @"sprites.plist";
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:bgPlist];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:fgPlist];
        
        // add background
        CCSprite *dirt = [CCSprite spriteWithSpriteFrameName:@"bg_dirt.png"];
        dirt.scale = 2.0;
        dirt.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:dirt z:-2];

        // add foreground
        CCSprite *lower = [CCSprite spriteWithSpriteFrameName:@"grass_lower.png"];
        lower.anchorPoint = ccp(0.5, 1);
        lower.position = dirt.position;
        [self addChild:lower z:1];
        
        CCSprite *upper = [CCSprite spriteWithSpriteFrameName:@"grass_upper.png"];
        upper.anchorPoint = ccp(0.5, 0);
        upper.position = dirt.position;
        [self addChild:upper z:-1];
        
        // load sprites
        CCSpriteBatchNode *spriteNode = [CCSpriteBatchNode batchNodeWithFile:sSheet];
        [self addChild:spriteNode z:0];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:sPlist];

        moles = [[NSMutableArray alloc] init];
        
        CCSprite *mole1 = [CCSprite spriteWithSpriteFrameName:@"mole_1.png"];
        mole1.position = [self convertPoint:ccp(85, 85)];
        [spriteNode addChild:mole1];
        [moles addObject:mole1];
        
        CCSprite *mole2 = [CCSprite spriteWithSpriteFrameName:@"mole_1.png"];
        mole2.position = [self convertPoint:ccp(240, 85)];
        [spriteNode addChild:mole2];
        [moles addObject:mole2];

        CCSprite *mole3 = [CCSprite spriteWithSpriteFrameName:@"mole_1.png"];
        mole3.position = [self convertPoint:ccp(395, 85)];
        [spriteNode addChild:mole3];
        [moles addObject:mole3];
        
        [self schedule:@selector(tryPopMoles:) interval:0.5];
        
        laughAnim = [self animationFormPlist:@"laughAnim" delay:0.1];
        hitAnim = [self animationFormPlist:@"hitAnim" delay:0.02];
        [[CCAnimationCache sharedAnimationCache] addAnimation:laughAnim name:@"laughAnim"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:hitAnim name:@"hitAnim"];
        
        self.isTouchEnabled = YES;
        
        float margin = 10;
        lblScore = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Verdana" fontSize:[self convertFontSize:14.0]];
        lblScore.anchorPoint = ccp(1, 0);
        lblScore.position = ccp(winSize.width - margin, margin);
        [self addChild:lblScore z:10];

        lblGameOver = [CCLabelTTF labelWithString:@"Level Complete!" fontName:@"Verdana" fontSize:[self convertFontSize:48.0]];
        lblGameOver.position = ccp(winSize.width/2, winSize.height/2);
        lblGameOver.visible = NO;
        [self addChild:lblGameOver z:10];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"laugh.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"ow.caf"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"whack.caf" loop:YES];
	}
	return self;
    

}

- (CGPoint)convertPoint:(CGPoint)point
{
    return hdFlg ? ccp(32 + point.x * 2, 64 + point.y*2) : point;
}

- (float)convertFontSize:(float)fontSize
{
    return hdFlg ? fontSize * 2 : fontSize;
}

- (CCAnimation *)animationFormPlist:(NSString *)animPlist delay:(float)delay
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:animPlist ofType:@"plist"];
    //NSLog(@"plistPath: %@", plistPath);
    NSArray *animImages = [NSArray arrayWithContentsOfFile:plistPath];
    //NSLog(@"animImages: %@", animImages);
    NSMutableArray *animFrames = [NSMutableArray array];
    
    for (NSString *animImage in animImages) {
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:animImage]];
    }
    
    return [CCAnimation animationWithFrames:animFrames delay:delay];
}

- (void)setTappable:(id)sender
{
    CCSprite *mole = (CCSprite *)sender;
    [mole setUserData:self];
    [[SimpleAudioEngine sharedEngine] playEffect:@"laugh.caf"];
}


- (void)unsetTappable:(id)sender
{
    CCSprite *mole = (CCSprite *)sender;
    [mole setUserData:FALSE];
}


- (void)popMole:(CCSprite *)mole
{
    if (totalSpawns > LEVEL1_MOLE_COUNT) return;
    totalSpawns++;
    
    [mole setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mole_1.png"]];
    
    CCMoveBy *moveUp = [CCMoveBy actionWithDuration:0.2 position:ccp(0, mole.contentSize.height)];
    CCCallFunc *setTappable = [CCCallFuncN actionWithTarget:self selector:@selector(setTappable:)];
    CCEaseInOut *easeMoveUp = [CCEaseInOut actionWithAction:moveUp rate:3.0];
    CCAction *easeMoveDown = [easeMoveUp reverse];
    CCCallFunc *unsetTappable = [CCCallFuncN actionWithTarget:self selector:@selector(unsetTappable:)];
    CCAnimate *laugh = [CCAnimate actionWithAnimation:laughAnim restoreOriginalFrame:YES];
    
    [mole runAction:[CCSequence actions:easeMoveUp, setTappable, laugh, unsetTappable, easeMoveDown, nil]];
}

- (void)resetGame
{
    lblGameOver.visible = false;
    totalSpawns = 0;
    gameOver = false;
    pauseTime = 0;
}

- (void)tryPopMoles:(ccTime)dt
{
    if(gameOver) {
        pauseTime += dt;
        if (pauseTime > 5.0) {
            [self resetGame];
        }
        return;
    }
    
    [lblScore setString:[NSString stringWithFormat:@"Score: %d", score]];
    
    if (totalSpawns >= LEVEL1_MOLE_COUNT) {
        lblGameOver.visible = true;
        lblGameOver.scale = 0.1;
        [lblGameOver runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
        
        gameOver = true;
        return;
    }
    
    for (CCSprite *mole in moles) {
        if(arc4random() % 3 == 0) {
            if (mole.numberOfRunningActions == 0) {
                [self popMole:mole];
            }
        }
    }
}

- (void)registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCMenuTouchPriority swallowsTouches:NO];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];

    for (CCSprite *mole in moles) {
        if(mole.userData == FALSE) continue;
        if(CGRectContainsPoint(mole.boundingBox, touchLocation)) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"ow.caf"];
            mole.userData = FALSE;
            score += 10;
            
            [mole stopAllActions];
            CCAnimate *hit = [CCAnimate actionWithAnimation:hitAnim restoreOriginalFrame:NO];
            CCMoveBy *moveDown = [CCMoveBy actionWithDuration:0.2 position:ccp(0, -mole.contentSize.height)];
            CCEaseInOut *easeMoveDown = [CCEaseInOut actionWithAction:moveDown rate:3.0];
            [mole runAction:[CCSequence actions:hit, easeMoveDown, nil]];
        }
    }
    
    return TRUE;
}

- (void)dealloc
{
    [moles release];
    moles = nil;
    
    [laughAnim release];
    laughAnim = nil;
    
    [hitAnim release];
    hitAnim = nil;
    
	[super dealloc];
}

@end
