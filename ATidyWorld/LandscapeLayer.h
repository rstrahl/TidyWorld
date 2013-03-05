//
//  LandscapeLayer.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-22.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "WeatherService.h"

@class SummerBaseLayer;

@interface LandscapeLayer : CCLayer <UIGestureRecognizerDelegate>
{    
    BOOL                    mOvercast;                      //< Indicates whether it is overcast
    BOOL                    mNightTime;                     //< Indicates whether it is night
    SummerBaseLayer         *mSceneDelegate;                //< Reference to the scene object
    CCSpriteBatchNode       *mLandscapeBatchNode;           //< Batch node for landscape sprites
    CCArray                 *mLandscapeForegroundArray;     //< Container array for all foreground landscape sprites
    CCArray                 *mLandscapeBackgroundArray;     //< Container array for all background landscape sprites
    CGFloat                 mVelocity;                      //< The horizontal velocity applied to sprites
    CGFloat                 mVelocityStep;                  //< The actual change in position applied to sprite.position
    UIPanGestureRecognizer  *mPanGestureRecognizer;         //< Pan gesture recognizer for handling user interaction
    CGSize                  mScreenSize;                    //< Size of the screen as reported by the director
    CGFloat                 mLandscapeSpriteWidth;          //< Width of a landscape sprite
    int                     mLastDaylightTint;
    int                     mLightningDecayRate;
    int                     mLastLightningTint;
}

@property (nonatomic, strong) SummerBaseLayer *sceneDelegate;
@property (nonatomic, assign, getter = isOvercast) BOOL overcast;

- (id)initWithSceneDelegate:(SummerBaseLayer *)sceneDelegate;

/** Updates the daylight tint value of all child nodes of this layer
 *  @param tintValue the new tint value
 */
- (void)updateDaylightTint:(int)tintValue;

- (void)cloudWillFireLightningEffectWithDecayRate:(int)lightningDecayRate;

@end
