//
//  SummerBaseLayer.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-01-27.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class ClockFaceView;
@class AdsViewController;
@class ButtonsViewController;
@class SkyLayer;

@interface SummerBaseLayer : CCLayer
{
    NSTimeInterval          mClockTime;
    ClockFaceView           *mClockFaceView;
    AdsViewController       *mAdsViewController;
    ButtonsViewController   *mButtonsViewController;
    NSInteger               mTimeLapseMultiplier;
    BOOL                    mIsTimeLapse;
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

}

@property (nonatomic, strong) ClockFaceView         *clockFaceView;
@property (nonatomic, strong) AdsViewController     *adsViewController;
@property (nonatomic, strong) ButtonsViewController *buttonsViewController;

// returns a CCScene that contains the SummerBaseLayer as the only child
+(CCScene *) scene;

@end
