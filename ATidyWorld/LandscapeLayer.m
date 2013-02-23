//
//  LandscapeLayer.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-22.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "LandscapeLayer.h"
#import "SummerBaseLayer.h"
#import "Constants.h"

@implementation LandscapeLayer

@synthesize sceneDelegate = mSceneDelegate;

- (id)initWithSceneDelegate:(SummerBaseLayer *)sceneDelegate
{
    if (self = [super init])
    {
        self.sceneDelegate = sceneDelegate;
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        mScreenSize = [[CCDirector sharedDirector] winSize];
        mVelocity = 100;
        
        mLandscapeForegroundArray = [[CCArray alloc] initWithCapacity:kLandscapeCount];
        mLandscapeBackgroundArray = [[CCArray alloc] initWithCapacity:kLandscapeCount];
        
        for (int i = 0; i < kLandscapeCount; i++)
        {
            CCSprite *landscapeForegroundSprite = [[CCSprite alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"LandscapeForeground%dTest.png", i+1]];
            landscapeForegroundSprite.position = ccp((i * landscapeForegroundSprite.boundingBox.size.width),
                                                     landscapeForegroundSprite.boundingBox.size.height);
            landscapeForegroundSprite.anchorPoint = ccp(0,1);
            [mLandscapeForegroundArray addObject:landscapeForegroundSprite];
            [sceneDelegate.landscapeBatchNode addChild:landscapeForegroundSprite];
            
            CCSprite *landscapeBackgroundSprite = [[CCSprite alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"LandscapeBackground%dTest.png", i+1]];
            landscapeBackgroundSprite.position = ccp((i * landscapeForegroundSprite.boundingBox.size.width),
                                                     (landscapeForegroundSprite.boundingBox.size.height + landscapeBackgroundSprite.boundingBox.size.height));
            landscapeBackgroundSprite.anchorPoint = ccp(0,1);
            [mLandscapeBackgroundArray addObject:landscapeBackgroundSprite];
            [sceneDelegate.landscapeBatchNode addChild:landscapeBackgroundSprite];
        }
        
        [self scheduleUpdate];
    }
    return self;
}

#pragma mark - Game Loop Update
- (void)update:(ccTime)deltaTime
{
    for (int i = 0; i < kLandscapeCount; i++)
    {
        CCSprite *foregroundLandscape = (CCSprite *)[mLandscapeForegroundArray objectAtIndex:i];
        CCSprite *backgroundLandscape = (CCSprite *)[mLandscapeBackgroundArray objectAtIndex:i];
        CGFloat dx = (mVelocity * deltaTime);
        foregroundLandscape.position = ccp(foregroundLandscape.position.x + dx, foregroundLandscape.position.y);
        backgroundLandscape.position = ccp(backgroundLandscape.position.x + (dx / 2), backgroundLandscape.position.y);
        
        [self updateParallaxEffectForLandscapeSprite:foregroundLandscape
                                             atIndex:i
                                           fromArray:mLandscapeForegroundArray];
        [self updateParallaxEffectForLandscapeSprite:backgroundLandscape
                                             atIndex:i
                                           fromArray:mLandscapeBackgroundArray];
    }
}

- (void)updateParallaxEffectForLandscapeSprite:(CCSprite *)sprite atIndex:(int)i fromArray:(CCArray *)array
{
    if (mVelocity > 0) // We're moving towards the right
    {
        if (sprite.position.x > mScreenSize.width) // Landscape moving offscreen towards right
        {
            // Set x to the x of the i+1 neighbor minus sprite width
            int n = (i+1 == kLandscapeCount) ? 0 : (i + 1);
            CCSprite *neighborLandscape = (CCSprite *)[array objectAtIndex:n];
            sprite.position = ccp(neighborLandscape.position.x - sprite.boundingBox.size.width, sprite.position.y);
        }
    }
    else if (mVelocity < 0) // We're moving towards the left
    {
        if ((sprite.position.x + sprite.boundingBox.size.width) < 0) // Landscape moving offscreen towards left
        {
            // Set x to the x of the i-1 neighbor plus sprite width
            int n = (i-1 < 0) ? (kLandscapeCount-1) : i-1;
            CCSprite *neighborLandscape = (CCSprite *)[array objectAtIndex:n];
            sprite.position = ccp(neighborLandscape.position.x + sprite.boundingBox.size.width, sprite.position.y);
        }
    }
}

#pragma mark - CCTargetedTouchDelegate
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // Cancel velocity of moving background sprites
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    // Get the new location
    // Get the previous location
    // Determine the direction of movement
    // Determine the "velocity" of movement
    // Set the velocity and direction of the background sprites    
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

@end
