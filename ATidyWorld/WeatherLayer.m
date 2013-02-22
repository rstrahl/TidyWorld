//
//  WeatherLayer.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-18.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "WeatherLayer.h"
#import "Constants.h"
#import "Cloud.h"
#import "RandomUtil.h"
#import "ColorConverter.h"
#import "SummerBaseLayer.h"

@interface WeatherLayer()
/** Initializes cloud sprites for the layer and adds them to the specified CCSpriteBatchNode,
 *  but stores them offscreen until they are added using {@link WeatherLayer
 *  @param spriteBatchNode the CCSpriteBatchNode that will handle cloud sprites
 */
- (void)setupCloudsWithSpriteBatchNode:(CCSpriteBatchNode *)spriteBatchNode;
/** Adds a specified number of Cloud sprites to the scene from the "cached" clouds array
 *  @param numClouds the number of cached Cloud sprites to add to the scene
 */
- (void)addCloudsToScene:(uint)numClouds;
/** Removes all Cloud sprites from the scene, returning them to a "cached" state
 */
- (void)removeCloudsFromScene;
/** Sets the current state of clouds
 *  @param cloudState the type of clouds to display if any
 */
- (void)setCloudsState:(WeatherConditionClouds)cloudsState;
/** Sets the current state of rain particles
 * @param rainState the type of rain to display if any
 */
- (void)setRainState:(WeatherConditionRain)rainState;
/** Sets the current state of snow particles
 * @param snowState the type of snow to display if any
 */
- (void)setSnowState:(WeatherConditionSnow)snowState;
/** Sets the current state of lightning effects if any
 * @param lightningState the type of lightning to display if any
 */
- (void)setLightningState:(WeatherConditionLightning)lightningState;
@end

@implementation WeatherLayer

@synthesize sceneDelegate = mSceneDelegate;


- (id)initWithSceneDelegate:(SummerBaseLayer *)sceneDelegate
{
    if (self = [super init])
    {
        self.sceneDelegate = sceneDelegate;
        
        // Init clouds
        [self setupCloudsWithSpriteBatchNode:sceneDelegate.spriteBatchNode];
        
        // Init particle systems for weather effects
        mSnowLightParticleSystem = [[CCParticleSystemQuad alloc] initWithFile:PARTICLE_FILE_SNOW_MEDIUM];
        mSnowHeavyParticleSystem = [[CCParticleSystemQuad alloc] initWithFile:PARTICLE_FILE_SNOW_HEAVY];
        mSnowBlizzardParticleSystem = [[CCParticleSystemQuad alloc] initWithFile:PARTICLE_FILE_SNOW_BLIZZARD];
        mSnowBlowingParticleSystem = [[CCParticleSystemQuad alloc] initWithFile:PARTICLE_FILE_SNOW_BLOWING];
        mRainLightParticleSystem = [[CCParticleSystemQuad alloc] initWithFile:PARTICLE_FILE_RAIN_LIGHT];
        mRainMediumParticleSystem = [[CCParticleSystemQuad alloc] initWithFile:PARTICLE_FILE_RAIN_MEDIUM];
        mRainHeavyParticleSystem = [[CCParticleSystemQuad alloc] initWithFile:PARTICLE_FILE_RAIN_HEAVY];
        
        [mRainLightParticleSystem setVisible:NO];
        [mRainMediumParticleSystem setVisible:NO];
        [mRainHeavyParticleSystem setVisible:NO];
        [mSnowLightParticleSystem setVisible:NO];
        [mSnowHeavyParticleSystem setVisible:NO];
        [mSnowBlowingParticleSystem setVisible:NO];
        [mSnowBlizzardParticleSystem setVisible:NO];
        
        [self addChild:mSnowLightParticleSystem];
        [self addChild:mSnowHeavyParticleSystem];
        [self addChild:mSnowBlizzardParticleSystem];
        [self addChild:mSnowBlowingParticleSystem];
        [self addChild:mRainLightParticleSystem];
        [self addChild:mRainMediumParticleSystem];
        [self addChild:mRainHeavyParticleSystem];
        
        [self scheduleUpdate];
    }
    return self;
}

- (void)update:(ccTime)deltaTime
{
    for(Cloud *cloud in mActiveCloudArray)
    {
        [cloud update:deltaTime];
    }
    if (mLightningActive)
    {
        mLightningTimerThreshold += deltaTime;
        if (mLightningTimerThreshold > kLightningThreshold)
        {
            [self willFireLightningAnimation];
        }
    }
}

#pragma mark - Properties
- (BOOL)isOvercast
{
    return mOvercast;
}

- (void)setOvercast:(BOOL)overcast
{
    mOvercast = overcast;
}

#pragma mark - Clouds

- (void)setupCloudsWithSpriteBatchNode:(CCSpriteBatchNode *)spriteBatchNode
{
    uint maxClouds = 4;
    mCloudArray = [[CCArray alloc] initWithCapacity:maxClouds];
    mActiveCloudArray = [[CCArray alloc] initWithCapacity:maxClouds];
    for (int i = 0; i < maxClouds; i++)
    {
        Cloud *cloud = [Cloud cloudWithTextureID:[RandomUtil getRandomMin:1 max:4]
                                           speed:(([RandomUtil getYesOrNo] + 1) * 5)
                                           scale:1.0f
                                       batchNode:spriteBatchNode];
        [mCloudArray addObject:cloud];
    }
}

- (void)addCloudsToScene:(uint)numClouds
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CGFloat maxY = screenSize.height - (screenSize.height / 6);
    CGFloat minY = maxY - (screenSize.height / 3);
    CGFloat x = 0;
    CGFloat y = 0;
    for (uint i = 0; i < numClouds; i++)
    {
        // Calculate next
        Cloud *cloud = [mCloudArray objectAtIndex:i];
        x = i * (cloud.cloudBase.boundingBox.size.width/2);
        y = [RandomUtil getRandomMin:minY max:maxY];
        cloud.position = ccp(x,y);
        [mActiveCloudArray addObject:cloud];
    }
}

- (void)removeCloudsFromScene
{
    for (Cloud *cloud in mActiveCloudArray)
    {
        cloud.position = kOffscreenSpritePoint;
        [cloud updatePosition:1];
    }
    [mActiveCloudArray removeAllObjects];
}

#pragma mark - Day/Night Cycle
- (void)updateDaylightTint:(int)tintValue
{
    float h = 0, s = 0, v = 0;
    int r = 0, g = 0, b = 0;
    v = (float)tintValue / 255;
    v = (v < kMinDaytimeTintValue) ? kMinDaytimeTintValue : v;
    if (mOvercast)
    {
        v = (v > kMaxOvercastTintValue) ? kMaxOvercastTintValue : v;
    }
    hsv_to_rgb(h, s, v, &r, &g, &b);

    for (Cloud *cloud in mCloudArray)
    {
        cloud.cloudBase.color = ccc3(r, g, b);
        cloud.cloudHighlight.opacity = 255 - tintValue;
        if (cloud.cloudHighlight.opacity < 1 ||
            mOvercast)
        {
            [cloud.cloudHighlight setVisible:NO];
        }
        else
        {
            [cloud.cloudHighlight setVisible:YES];
        }
    }
}

#pragma mark - Weather Conditions
- (void)setWeatherCondition:(WeatherCondition)condition
{
    [self setLightningState:condition.lightning];
    [self setRainState:condition.rain];
    [self setSnowState:condition.snow];
    [self setCloudsState:condition.clouds];
//    [self setFogState:condition.fog];
    mCurrentWeatherCondition = condition;
}

- (void)setCloudsState:(WeatherConditionClouds)cloudsState
{
    if (cloudsState != mCurrentWeatherCondition.clouds)
    {
        [self removeCloudsFromScene];
        switch (cloudsState)
        {
            case WeatherCloudsPartial:
            {
                [self addCloudsToScene:2];
                break;
            }
            case WeatherCloudsMostly:
            {
                [self addCloudsToScene:4];
                break;
            }
            case WeatherCloudsOvercast:
            {
                [self addCloudsToScene:4];
                break;
            }
            case WeatherCloudsNone:
            default:
            {
                break;
            }
        }
    }
}

- (void)setRainState:(WeatherConditionRain)rainState
{
    if (rainState != mCurrentWeatherCondition.rain)
    {
        [mRainLightParticleSystem setVisible:NO];
        [mRainMediumParticleSystem setVisible:NO];
        [mRainHeavyParticleSystem setVisible:NO];
        [mRainLightParticleSystem stopSystem];
        [mRainMediumParticleSystem stopSystem];
        [mRainHeavyParticleSystem stopSystem];
        switch (rainState)
        {
            case WeatherRainLight:
            {
                [mRainLightParticleSystem setVisible:YES];
                [mRainLightParticleSystem resetSystem];
                break;
            }
            case WeatherRainMedium:
            {
                [mRainMediumParticleSystem setVisible:YES];
                [mRainMediumParticleSystem resetSystem];
                break;
            }
            case WeatherRainHeavy:
            {
                [mRainHeavyParticleSystem setVisible:YES];
                [mRainHeavyParticleSystem resetSystem];
                break;
            }
            case WeatherRainNone:
            default:
            {
                break;
            }
        }
    }
}

- (void)setSnowState:(WeatherConditionSnow)snowState
{
    if (snowState != mCurrentWeatherCondition.snow)
    {
        [mSnowLightParticleSystem setVisible:NO];
        [mSnowHeavyParticleSystem setVisible:NO];
        [mSnowBlowingParticleSystem setVisible:NO];
        [mSnowBlizzardParticleSystem setVisible:NO];
        [mSnowLightParticleSystem stopSystem];
        [mSnowHeavyParticleSystem stopSystem];
        [mSnowBlowingParticleSystem stopSystem];
        [mSnowBlizzardParticleSystem stopSystem];
        switch (snowState)
        {
            case WeatherSnowLight:
            {
                [mSnowLightParticleSystem setVisible:YES];
                [mSnowLightParticleSystem resetSystem];
                break;
            }
            case WeatherSnowMedium:
            {
                [mSnowHeavyParticleSystem setVisible:YES];
                [mSnowHeavyParticleSystem resetSystem];
                break;
            }
            case WeatherSnowBlizzard:
            {
                [mSnowBlizzardParticleSystem setVisible:YES];
                [mSnowBlizzardParticleSystem resetSystem];
                break;
            }
            case WeatherSnowBlowing:
            {
                [mSnowBlowingParticleSystem setVisible:YES];
                [mSnowBlowingParticleSystem resetSystem];
                break;
            }
            case WeatherSnowNone:
            default:
            {
                break;
            }
        }
    }
}

- (void)setLightningState:(WeatherConditionLightning)lightningState
{
    if (lightningState != mCurrentWeatherCondition.lightning)
    {
        switch (lightningState)
        {
            case WeatherLightning:
            {
                mLightningActive = YES;
                break;
            }
            case WeatherLightningNone:
            default:
            {
                mLightningActive = NO;
                break;
            }
        }
    }
}

- (void)willFireLightningAnimation
{
    float rand = [RandomUtil getRandom0and1];
    DLog(@"Random test value for strike = %.2f", rand);
    if (rand < 0.25)
    {
        // Find a random cloud and trigger the lightning
        int cloudIndex = arc4random_uniform(mActiveCloudArray.count - 1);
        Cloud *cloud = (Cloud *)[mActiveCloudArray objectAtIndex:cloudIndex];
        [cloud fireLightningAnimationWithBolt:[RandomUtil getYesOrNo]];
        mLightningTimerThreshold = 0;
    }
}

@end
