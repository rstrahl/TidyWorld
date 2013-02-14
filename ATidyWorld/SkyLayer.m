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
        [self scheduleUpdate];
        mSkyGradient = [[SkyGradient alloc] init];
        mDuskDawnGradient = [[SkyDawnDuskGradient alloc] init];
        [self addChild:mSkyGradient];
        [self addChild:mDuskDawnGradient];
    }
    return self;
}

- (void)update:(ccTime)deltaTime
{
    
}

#pragma mark - Day/Night Cycle
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
