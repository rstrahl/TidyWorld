//
//  ParallaxLayer.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-03-04.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ParallaxLayer.h"

@implementation ParallaxLayer

@synthesize sceneDelegate = mSceneDelegate;

- (id)initWithSpriteBatchNode:(CCSpriteBatchNode *)batchNode
{
    if (self = [super init])
    {
        mScreenSize = [[CCDirector sharedDirector] winSize];
        mParallaxSpriteArray = [[CCArray alloc] initWithCapacity:1];
        [self scheduleUpdate];
    }
    return self;
}

- (void)setVisible:(BOOL)visible
{
    [super setVisible:visible];
    for (CCSprite *sprite in mParallaxSpriteArray)
    {
        sprite.visible = visible;
    }
}

#pragma mark - Game Loop Update
- (void)update:(ccTime)deltaTime
{
    if (self.visible)
    {
        // Update position
        mVelocityStep += (mVelocity * deltaTime);
        if (fabsf(mVelocityStep) >= 1)
        {
            [self updateSpritePositionsWithDelta:mVelocityStep];
            if (mVelocityStep > 1)
            {
                mVelocityStep -= floorf(mVelocityStep);
            }
            if (mVelocityStep < -1)
            {
                mVelocityStep += floorf(mVelocityStep);
            }
        }
        mVelocityStep -= floorf(mVelocityStep);
    }
}

- (void)updateSpritePositionsWithDelta:(CGFloat)dx
{
    dx = (dx > 0) ? floorf(dx) : floorf(dx);
    
    for (int i = 0; i < mSpriteCount; i++)
    {
        CCSprite *sprite = (CCSprite *)[mParallaxSpriteArray objectAtIndex:i];
        sprite.position = ccp((sprite.position.x + dx), sprite.position.y);
    }
    
    for (int i = 0; i < mSpriteCount; i++)
    {
        CCSprite *sprite = (CCSprite *)[mParallaxSpriteArray objectAtIndex:i];
        [self updateParallaxEffectForLandscapeSprite:sprite
                                             atIndex:i
                                           withDelta:dx];
    }
}

- (void)updateParallaxEffectForLandscapeSprite:(CCSprite *)sprite atIndex:(int)i withDelta:(CGFloat)dx
{
    if (dx > 0) // We're moving towards the right
    {
        if (sprite.position.x >= mScreenSize.width) // Landscape moving offscreen towards right
        {
            // Set x to the x of the i+1 neighbor minus sprite width
            int n = (i+1 == mSpriteCount) ? 0 : (i + 1);
            CCSprite *neighborSprite = (CCSprite *)[mParallaxSpriteArray objectAtIndex:n];
            sprite.position = ccp(ceilf(neighborSprite.position.x - mSpriteSize.width), floorf(sprite.position.y));
        }
    }
    else if (dx < 0) // We're moving towards the left
    {
        if ((sprite.position.x + mSpriteSize.width) <= 0) // Landscape moving offscreen towards left
        {
            // Set x to the x of the i-1 neighbor plus sprite width
            int n = (i-1 < 0) ? (mSpriteCount - 1) : (i - 1);
            CCSprite *neighborSprite = (CCSprite *)[mParallaxSpriteArray objectAtIndex:n];
            sprite.position = ccp(floorf(neighborSprite.position.x + mSpriteSize.width), floorf(sprite.position.y));
        }
    }
}

@end
