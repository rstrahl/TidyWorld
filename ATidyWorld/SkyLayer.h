//
//  SkyLayer.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-12.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class SkyGradient;
@class DawnDuskGradient;
@class SunMoonSprite;
@class SummerBaseLayer;

/** The top-level Layer that manages child nodes in the sky such as stars, sun, moon, etc. Most of the 
 *  child nodes will have their update methods called directly from this layer because they need
 *  awareness of the current time, as well as time of sunrise and sunset.  This layer has several update
 *  methods, all of which are called under different conditions from the scene object.
 */
@interface SkyLayer : CCLayer
{
    @private
    SkyGradient             *mSkyGradient;
    DawnDuskGradient        *mDuskDawnGradient;
    SunMoonSprite           *mSunMoonSprite;
    CCSpriteBatchNode       *mSkyBatchNode;
    CCParticleSystemQuad    *mStarsParticleSystem;
    CCSprite                *mBlinkingStar;
    NSTimeInterval          mBlinkTimeCounter;
    BOOL                    mOvercast;
    BOOL                    mNightTime;
    id                      mSceneDelegate;
}

@property (nonatomic, assign) id sceneDelegate;

- (id)initWithSceneDelegate:(SummerBaseLayer *)sceneDelegate;

- (BOOL)isOvercast;
- (void)setOvercast:(BOOL)overcast;
- (BOOL)isNightTime;
- (void)setNightTime:(BOOL)nightTime;

/** Updates any children that are affected by the time of day
 *  @param time the current time in the given day
 *  @param sunriseTime the time of sunrise in the given day
 *  @param sunsetTime the time of sunset in the given day 
 */
- (void)updateForTime:(NSTimeInterval)time sunriseTime:(NSTimeInterval)sunriseTime sunsetTime:(NSTimeInterval)sunsetTime;
/** Updates the daylight tint value of all child nodes of this layer 
 *  @param tintValue the new tint value 
 */
- (void)updateDaylightTint:(int)tintValue;
/** Updates the progress of all child nodes involved in sunrise effects 
 */
- (void)updateSunriseProgress:(float)progress;
/** Updates the progress of all child nodes involved in sunset effects 
 */
- (void)updateSunsetProgress:(float)progress;
@end
