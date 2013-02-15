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
#import "SkyDawnDuskGradient.h"
#import "SunSprite.h"

// Private Interface
@interface SkyLayer()

@end
// -----------------

@implementation SkyLayer

@synthesize overcast = mOvercast;

- (id)init
{
    if (self = [super init])
    {
//        [self scheduleUpdate];
        mSkyGradient = [[SkyGradient alloc] init];
        mDuskDawnGradient = [[SkyDawnDuskGradient alloc] init];
        CGSize screenSize = [[CCDirector sharedDirector] view].frame.size;
        mSunMoonSprite = [[SunSprite alloc] initAtPoint:CGPointMake((screenSize.width / 2), (screenSize.height / 2))];
        [self addChild:mSkyGradient];
        [self addChild:mDuskDawnGradient];
        [self addChild:mSunMoonSprite];
    }
    return self;
}

- (void)update:(ccTime)deltaTime
{
    
}

#pragma mark - Day/Night Cycle
- (void)updateChildPositionsForTime:(NSTimeInterval)time sunriseTime:(NSTimeInterval)sunriseTime sunsetTime:(NSTimeInterval)sunsetTime
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
}

- (void)updateSunsetProgress:(float)progress
{
    if (!mOvercast)
    {
        [mDuskDawnGradient setEffectProgress:progress forEffectType:SkyEffectTypeDusk];
    }
}

@end
