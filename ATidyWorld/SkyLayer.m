//
//  SkyLayer.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-12.
//  Copyright 2013 Rudi Strahl. All rights reserved.
//

#import "SkyLayer.h"
#import "ColorConverter.h"
#import "SkyGradient.h"
#import "DawnDuskGradient.h"
#import "SunMoonSprite.h"
#import "RandomUtil.h"
#import "Constants.h"
#import "SummerBaseLayer.h"

// Private Interface
@interface SkyLayer()
- (void)initStars;
@end
// -----------------

@implementation SkyLayer

@synthesize sceneDelegate = mSceneDelegate;

- (id)initWithSceneDelegate:(SummerBaseLayer *)sceneDelegate
{
    if (self = [super init])
    {
        self.sceneDelegate = sceneDelegate;
        CGSize screenSize = [[CCDirector sharedDirector] view].frame.size;
                
        // Base sky
        mSkyGradient = [[SkyGradient alloc] init];
        [self addChild:mSkyGradient];
        
        // Dusk/Dawn gradient effect
        mDuskDawnGradient = [[DawnDuskGradient alloc] init];
        [self addChild:mDuskDawnGradient];
        
        // Stars
        mStarsParticleSystem = [[CCParticleSystemQuad alloc] initWithFile:PARTICLE_FILE_STARS];
        [mStarsParticleSystem setVisible:NO];
        [self addChild:mStarsParticleSystem];
        
        // Sun/Moon
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SPRITESHEET_SKY_PLIST];
        mSkyBatchNode = [[CCSpriteBatchNode alloc] initWithFile:SPRITESHEET_SKY_IMAGE capacity:4];
        [self addChild:mSkyBatchNode];

        CGPoint sunMoonPoint = CGPointMake((screenSize.width / 2), 55);
        mSunMoonSprite = [[SunMoonSprite alloc] initAtPoint:sunMoonPoint batchNode:mSkyBatchNode];
        
//        [self scheduleUpdate];
    }
    return self;
}

- (void)update:(ccTime)deltaTime
{
}

#pragma mark - Properties
- (BOOL)isNightTime
{
    return mNightTime;
}

- (void)setNightTime:(BOOL)nightTime
{
    mNightTime = nightTime;
    [self initStars];
}

- (BOOL)isOvercast
{
    return mOvercast;
}

- (void)setOvercast:(BOOL)overcast
{
    mOvercast = overcast;
    [mSkyGradient setOvercast:overcast];
    [mSunMoonSprite setOvercast:overcast];
    [self initStars];
}

#pragma mark - Day/Night Cycle
- (void)updateForTime:(NSTimeInterval)time sunriseTime:(NSTimeInterval)sunriseTime sunsetTime:(NSTimeInterval)sunsetTime
{
    [mSunMoonSprite updatePositionForTime:time sunriseTime:sunriseTime sunsetTime:sunsetTime];
}

- (void)updateDaylightTint:(int)tintValue
{
    [mSkyGradient setDaylightTintValue:tintValue];
}

- (void)updateSunriseProgress:(float)progress
{
    if (!mOvercast)
    {
        [mDuskDawnGradient setEffectProgress:progress forEffectType:SkyEffectTypeDawn];
    }
    else
    {
        if (mDuskDawnGradient.visible)
        {
            [mDuskDawnGradient setVisible:NO];
        }
    }
}

- (void)updateSunsetProgress:(float)progress
{
    if (!mOvercast)
    {
        [mDuskDawnGradient setEffectProgress:progress forEffectType:SkyEffectTypeDusk];
    }
    else
    {
        if (mDuskDawnGradient.visible)
        {
            [mDuskDawnGradient setVisible:NO];
        }
    }
}

- (void)initStars
{
    if (mNightTime && !mOvercast)
    {
        [mStarsParticleSystem setDuration:-1];
        [mStarsParticleSystem resetSystem];
        [mStarsParticleSystem setVisible:YES];
    }
    else
    {
        [mStarsParticleSystem setDuration:0];
        [mStarsParticleSystem setVisible:NO];
    }
}

@end
