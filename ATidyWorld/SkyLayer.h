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
@class SkyDawnDuskGradient;
@class SunSprite;

@interface SkyLayer : CCLayer
{
    @private
    SkyGradient         *mSkyGradient;
    SkyDawnDuskGradient *mDuskDawnGradient;
    SunSprite           *mSunMoonSprite;
    // TODO: Add stars
    BOOL                mOvercast;
}

@property (nonatomic, assign, getter = isOvercast) BOOL overcast;

/** Updates the positions of any children that are affected by the time of day
    @param time the current time in the given day
    @param sunriseTime the time of sunrise in the given day
    @param sunsetTime the time of sunset in the given day */
- (void)updateChildPositionsForTime:(NSTimeInterval)time sunriseTime:(NSTimeInterval)sunriseTime sunsetTime:(NSTimeInterval)sunsetTime;
/** Updates the daylight tint value of all child nodes of this layer 
    @param tintValue the new tint value */
- (void)updateDaylightTint:(int)tintValue;
/** Updates the progress of all child nodes involved in sunrise effects */
- (void)updateSunriseProgress:(float)progress;
/** Updates the progress of all child nodes involved in sunset effects */
- (void)updateSunsetProgress:(float)progress;
@end
