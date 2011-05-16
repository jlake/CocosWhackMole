//
//  GameLayer.m
//  CocosWhackMole
//
//  Created by 欧 on 11/05/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"


@implementation GameLayer

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
    
	return scene;
}


- (void)dealloc
{
    
	[super dealloc];
}

@end
