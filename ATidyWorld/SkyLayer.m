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
#import "SunMoonSprite.h"
#import "RandomUtil.h"
#import "Constants.h"

// Private Interface
@interface SkyLayer()
/** Initializes the stars for the sky layer of a specified size and adds them to the layer for display
    @param size the size of the sky layer to fill */
- (void)initStarsForScreenSize:(CGSize)size;
@end
// -----------------

@implementation SkyLayer

@synthesize overcast = mOvercast,
            nightTime = mNightTime;

- (id)init
{
    if (self = [super init])
    {
        CGSize screenSize = [[CCDirector sharedDirector] view].frame.size;
        
        // Base sky
        mSkyGradient = [[SkyGradient alloc] init];
        [self addChild:mSkyGradient];
        
        // Stars
        [self initStarsForScreenSize:screenSize];
        
        // Dusk/Dawn gradient effect
        mDuskDawnGradient = [[SkyDawnDuskGradient alloc] init];
        [self addChild:mDuskDawnGradient];
        
        // Sun/Moon
        mSunMoonSprite = [[SunMoonSprite alloc] initAtPoint:CGPointMake((screenSize.width / 2), (screenSize.height / 2))];
        [self addChild:mSunMoonSprite];
        
        [self scheduleUpdate];
    }
    return self;
}

- (void)update:(ccTime)deltaTime
{
    if (mNightTime)
    {
        mBlinkTimeCounter += deltaTime;
        if (mBlinkTimeCounter > 0.1)
        {
            mBlinkingStar.opacity = 255;
            mBlinkTimeCounter = 0;
            [mBlinkingStar release];
            [self animateStar];
        }
    }
}

#pragma mark - Day/Night Cycle
- (void)updateForTime:(NSTimeInterval)time sunriseTime:(NSTimeInterval)sunriseTime sunsetTime:(NSTimeInterval)sunsetTime
{
    [mSunMoonSprite updatePositionForTime:time sunriseTime:sunriseTime sunsetTime:sunsetTime];
}

- (void)updateDaylightTint:(int)tintValue
{
    [mSkyGradient setDaylightTintValue:tintValue];
    
    // Fade in stars at night - inverse of daylight tint
    CCArray *stars = [mStarsNode children];
    for (CCSprite *star in stars)
    {
        star.opacity = 255 - tintValue;
    }
    mNightTime = (tintValue == 255) ? NO : YES;
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

- (void)initStarsForScreenSize:(CGSize)size
{
    mStarsNode = [CCSpriteBatchNode batchNodeWithFile:SPRITESHEET_IMAGE];
    uint starCount = (uint)[RandomUtil getRandomMin:100 max:150];
    float bigStarChance = 0.2;
    for (int i = 0; i < starCount; i++)
    {
        float starSize = [RandomUtil getRandom0and1];
        float scale = 1.0f;
        if (starSize > bigStarChance)
            scale = 0.5f;
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Star.png"];
        sprite.position = CGPointMake(arc4random_uniform(size.width), arc4random_uniform(size.height));
        sprite.scale = scale;
        [mStarsNode addChild:sprite];
    }
    [self addChild:mStarsNode];
}

- (void)animateStar
{
    CCArray *stars = [mStarsNode children];
    mBlinkingStar = [[stars objectAtIndex:[RandomUtil getRandomMin:0 max:(stars.count - 1)]] retain];
    [mBlinkingStar setOpacity:0];
}

@end
