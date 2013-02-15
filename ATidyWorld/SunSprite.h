//
//  SunSprite.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/** A game object containing both sun and moon sprites, able to rotate around a given point in coordinate space based on the 
    time of day in a given day.  The sun and moon rotate on opposite coordinates, and their location is updated synchronously.
 */
@interface SunSprite : CCNode
{
    CCSprite        *mSunSprite;                //< Sprite object representing the sun
    CCSprite        *mMoonSprite;               //< Sprite object representing the moon
    double          mSpriteRotationRadius;      //< Rotation radius of the sun
    double          mSpriteRotationSpeed;       //< Rotation speed of the sun
    double          mSpriteRotationAngle;       //< Rotation angle of the sun
    CGPoint         mRotationPoint;             //< the point in coordinate space the sun rotates around
}

- (id)initAtPoint:(CGPoint)point;

@property (nonatomic, strong) CCSprite *sprite;

/** Updates the position of the sun and moon based on the current time within a given day
    @param time the current time for the given day
    @param sunriseTime the time of sunrise for a given day 
    @param sunsetTime the time of sunset for a given day */
- (void)updatePositionForTime:(NSTimeInterval)time sunriseTime:(NSTimeInterval)sunriseTime sunsetTime:(NSTimeInterval)sunsetTime;

@end
