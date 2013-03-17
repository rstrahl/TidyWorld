//
//  FogLayer.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-03-04.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FogLayer.h"

const int kFogSpriteCount = 6; // Fog is 256 wide, we need at least 3 to cover parallaxing

@implementation FogLayer

- (id)initWithSpriteBatchNode:(CCSpriteBatchNode *)batchNode
{
    if (self = [super initWithSpriteBatchNode:batchNode])
    {
        mVelocity = 25;
        for (int i = 0; i < kFogSpriteCount; i++)
         {
             CCSprite *sprite = [[CCSprite alloc] initWithSpriteFrameName:@"Fog.png"];
             
             // Set position of sprite
             sprite.position = ccp((i * sprite.boundingBox.size.width), sprite.boundingBox.size.height);
             sprite.anchorPoint = ccp(0,1);
             sprite.opacity = 200;
             [mParallaxSpriteArray addObject:sprite];
             
             // Add sprite to spritebatchnode
             [batchNode addChild:sprite];
             
             if (mSpriteSize.width == 0)
             {
                  mSpriteSize = sprite.boundingBox.size;
             }
         }
        mSpriteCount = mParallaxSpriteArray.count;
    }
    return self;
}

@end
