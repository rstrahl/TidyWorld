//
//  WeatherLayer.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-18.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "WeatherService.h"

@class SummerBaseLayer;
@class FogLayer;

@interface WeatherLayer : CCLayer
{
    CCSpriteBatchNode       *mWeatherBatchNode;
    CCParticleSystemQuad    *mSnowLightParticleSystem;
    CCParticleSystemQuad    *mSnowHeavyParticleSystem;
    CCParticleSystemQuad    *mSnowBlowingParticleSystem;
    CCParticleSystemQuad    *mSnowBlizzardParticleSystem;
    CCParticleSystemQuad    *mRainLightParticleSystem;
    CCParticleSystemQuad    *mRainMediumParticleSystem;
    CCParticleSystemQuad    *mRainHeavyParticleSystem;
    CCSpriteBatchNode       *mCloudSpriteBatchNode;
    CCArray                 *mCloudArray;
    CCArray                 *mActiveCloudArray;
    FogLayer                *mFogLayer;
    SummerBaseLayer         *mSceneDelegate;
    BOOL                    mLightningActive;
    float                   mLightningTimerThreshold;
    BOOL                    mOvercast;
}

@property (nonatomic, strong) SummerBaseLayer *sceneDelegate;

- (id)initWithSceneDelegate:(SummerBaseLayer *)sceneDelegate;

- (BOOL)isOvercast;
- (void)setOvercast:(BOOL)overcast;

/** Sets the current weather conditions to display
 *  @param condition the weather conditions to display
 */
- (void)setWeatherCondition:(WeatherCondition)effect;

/** Updates the daylight tint value of all child nodes of this layer
 *  @param tintValue the new tint value
 */
- (void)updateDaylightTint:(int)tintValue;

@end
