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

@interface SkyLayer : CCLayer
{
    @private
    SkyGradient         *mSkyGradient;
    SkyDawnDuskGradient *mDuskDawnGradient;
    CCSprite            *mSun;
    CCSprite            *mMoon;
    // TODO: Add stars
    BOOL                mOvercast;
}

@property (nonatomic, assign, getter = isOvercast) BOOL overcast;

/** Updates the daylight tint value of all child nodes of this layer 
    @param tintValue the new tint value */
- (void)updateDaylightTint:(int)tintValue;
/** Updates the progress of all child nodes involved in sunrise effects */
- (void)updateSunriseProgress:(float)progress;
/** Updates the progress of all child nodes involved in sunset effects */
- (void)updateSunsetProgress:(float)progress;
@end
