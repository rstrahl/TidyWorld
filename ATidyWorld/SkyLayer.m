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
/** Initializes the stars for the sky layer of a specified size and adds them to the layer for display
 *  @param size the size of the sky layer to fill 
 */
- (void)initStarsForScreenSize:(CGSize)size;
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
//        [self initStarsForScreenSize:screenSize];
        mStarsParticleSystem = [[CCParticleSystemQuad alloc] initWithFile:PARTICLE_FILE_STARS];
        [mStarsParticleSystem setVisible:NO];
        [self addChild:mStarsParticleSystem];
        
        // Sun/Moon
        CGPoint sunMoonPoint = CGPointMake((screenSize.width / 2), (screenSize.height / 2));
        mSunMoonSprite = [[SunMoonSprite alloc] initAtPoint:sunMoonPoint batchNode:sceneDelegate.spriteBatchNode];
        
//        [self scheduleUpdate];
    }
    return self;
}

- (void)update:(ccTime)deltaTime
{
//    if (mNightTime)
//    {
//        mBlinkTimeCounter += deltaTime;
//        if (mBlinkTimeCounter > 0.1)
//        {
//            mBlinkingStar.opacity = 255;
//            mBlinkTimeCounter = 0;
//            [mBlinkingStar release];
//            [self animateStar];
//        }
//    }
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
    
    // Fade in stars at night - inverse of daylight tint
//    CCArray *stars = [mStarsNode children];
//    for (CCSprite *star in stars)
//    {
//        star.opacity = 255 - tintValue;
//    }
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

- (void)animateStar
{
    CCArray *stars = [mStarsNode children];
    mBlinkingStar = [[stars objectAtIndex:[RandomUtil getRandomMin:0 max:(stars.count - 1)]] retain];
    [mBlinkingStar setOpacity:0];
}

@end
