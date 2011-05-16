//
//  GameLayer.h
//  CocosWhackMole
//
//  Created by 欧 on 11/05/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

extern int const LEVEL1_MOLE_COUNT;

@interface GameLayer : CCLayer {
@protected
    BOOL hdFlg;
    CGSize winSize;
@private
    NSMutableArray *moles;
    CCAnimation *laughAnim;
    CCAnimation *hitAnim;
    
    CCLabelTTF *lblScore;
    CCLabelTTF *lblGameOver;
    
    int score;
    int totalSpawns;
    BOOL gameOver;
    ccTime pauseTime;
}

+ (CCScene *)scene;

- (CGPoint)convertPoint:(CGPoint)point;
- (float)convertFontSize:(float)fontSize;
- (CCAnimation *)animationFormPlist:(NSString *)animPlist delay:(float)delay;

@end
