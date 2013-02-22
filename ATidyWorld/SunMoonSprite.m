//
//  SunSprite.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SunMoonSprite.h"
#import "Constants.h"
#import "TMTimeUtils.h"

@implementation SunMoonSprite

@synthesize sprite = mSunSprite;

- (id)initAtPoint:(CGPoint)point batchNode:(CCSpriteBatchNode *)batchNode
{
    if (self = [super init])
    {
        mSunSprite = [CCSprite spriteWithSpriteFrameName:@"Sun.png"];
        mMoonSprite = [CCSprite spriteWithSpriteFrameName:@"Moon.png"];
        mRotationPoint = point;
        mSpriteRotationRadius = mRotationPoint.x;
        [batchNode addChild:mSunSprite];
        [batchNode addChild:mMoonSprite];
    }
    return self;
}

- (void)setOvercast:(BOOL)overcast
{
    mOvercast = overcast;
    if (overcast)
    {
        [mSunSprite setVisible:NO];
        [mMoonSprite setVisible:NO];
    }
    else
    {
        [mSunSprite setVisible:YES];
        [mMoonSprite setVisible:YES];
    }
}

- (void)updatePositionForTime:(NSTimeInterval)time sunriseTime:(NSTimeInterval)sunriseTime sunsetTime:(NSTimeInterval)sunsetTime
{
    if (time > sunriseTime && time < sunsetTime) // Rotation speed in daylight
    {
        mSpriteRotationSpeed = sunsetTime - sunriseTime;
        mSpriteRotationAngle = M_PI - ((time - sunriseTime) / (mSpriteRotationSpeed / M_PI));
    }
    else // Rotation speed in night
    {
        mSpriteRotationSpeed = sunriseTime + (kOneDayInSeconds - sunsetTime);
        if (time < sunriseTime) // Before sunrise
        {
            mSpriteRotationAngle = M_PI - ((kOneDayInSeconds - sunsetTime) + time);
        }
        else // After sunset
        {
            mSpriteRotationAngle = M_PI - (time - sunsetTime);
        }
        mSpriteRotationAngle /= (mSpriteRotationSpeed / M_PI);
    }
    CGFloat x = (mSpriteRotationRadius * (0.85*cos(mSpriteRotationAngle)) + mRotationPoint.x);
    CGFloat y = (mSpriteRotationRadius * sin(mSpriteRotationAngle) + mRotationPoint.y);
    
    mSunSprite.position = ccp(x, y);
    mMoonSprite.position = ccp(mRotationPoint.x + (mRotationPoint.x - x), (mRotationPoint.y + (mRotationPoint.y - y)));
}

@end
