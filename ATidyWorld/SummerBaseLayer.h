//
//  SummerBaseLayer.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-01-27.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "WorldOptionsViewController.h"

@class ClockFaceView;
@class AdsViewController;
@class ButtonsViewController;
@class SkyLayer;
@class WeatherLayer;
@class LandscapeLayer;

@interface SummerBaseLayer : CCLayer <WorldOptionsViewControllerDelegate>
{
    NSTimeInterval          mClockTime;
    ClockFaceView           *mClockFaceView;
    AdsViewController       *mAdsViewController;
    ButtonsViewController   *mButtonsViewController;
    NSInteger               mTimeLapseMultiplier;
    BOOL                    mUsingTimeLapse;
    BOOL                    mUsingLocationBasedWeather;
    BOOL                    mOvercast;
    int                     mNight;
    NSTimeInterval          mTimeOfSunriseInSeconds;
    NSTimeInterval          mTimeOfSunsetInSeconds;
    NSTimeInterval          mDaylightDuration;
    NSTimeInterval          mSunriseEffectStartTime;
    NSTimeInterval          mSunriseGlowStartTime;
    NSTimeInterval          mSunsetEffectStartTime;
    NSTimeInterval          mSunsetGlowStartTime;
    NSTimeInterval          mSunriseDuration;
    NSTimeInterval          mSunsetDuration;
    NSTimeInterval          mLastDaylightTintValue;
    NSTimeInterval          mLastSunriseProgress;
    NSTimeInterval          mLastSunsetProgress;
    // Layers
    SkyLayer                *mSkyLayer;
    WeatherLayer            *mWeatherLayer;
    LandscapeLayer          *mLandscapeLayer;
    
    // Sprite Batch Nodes
    CCSpriteBatchNode       *mSpriteBatchNode;
    CCParticleBatchNode     *mParticleBatchNode;
    CCSpriteBatchNode       *mLandscapeBatchNode;

}

@property (nonatomic, strong) ClockFaceView         *clockFaceView;
@property (nonatomic, strong) AdsViewController     *adsViewController;
@property (nonatomic, strong) ButtonsViewController *buttonsViewController;
@property (nonatomic, strong) CCSpriteBatchNode     *spriteBatchNode;
@property (nonatomic, strong) CCParticleBatchNode   *particleBatchNode;
@property (nonatomic, strong) CCSpriteBatchNode     *landscapeBatchNode;

@property (nonatomic, assign, getter = isUsingTimeLapse) BOOL usingTimeLapse;
@property (nonatomic, assign, getter = isUsingLocationBasedWeather) BOOL usingLocationBasedWeather;
@property (nonatomic, assign, getter = isOvercast) BOOL overcast;

// returns a CCScene that contains the SummerBaseLayer as the only child
+(CCScene *) scene;

@end
