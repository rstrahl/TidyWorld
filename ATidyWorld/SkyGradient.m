//
//  SkyGradient.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SkyGradient.h"
#import "ColorConverter.h"
#import "Constants.h"

// Sky Colors
const ccColor4B kSkyColorStorm          = {50, 50, 50, 255};
const ccColor4B kHorizonColorStorm      = {153, 153, 153, 255};
const ccColor4B kSkyColorDaylight       = {0, 142, 255, 255};
const ccColor4B kHorizonColorDaylight   = {218, 234, 255, 255};

@interface SkyGradient()
/** Updates the tint value for the sky, causing the sky colours to change. Colour changes are
 *  done via manipulation of Value (V in HSV). 
 */
- (void)updateDaylightTint;
@end


@implementation SkyGradient

- (id)init
{
    if (self = [super initWithColor:kSkyColorDaylight fadingTo:kHorizonColorDaylight])
    {
        [self scheduleUpdate];
        [self setBlendFunc:(ccBlendFunc){GL_ONE, GL_ZERO}];
    }
    return self;
}

#pragma mark - Properties
- (BOOL)isOvercast
{
    return mOvercast;
}

- (void)setOvercast:(BOOL)overcast
{
    mOvercast = overcast;
    [self updateDaylightTint];
}

#pragma mark - Game Loop Update

- (void)setDaylightTintValue:(GLubyte)tintValue
{
    mDaylightTintValue = tintValue;
    mNeedsRedraw = YES;
}

- (void)update:(ccTime)deltaTime
{
    if (mNeedsRedraw)
    {
        [self updateDaylightTint];
        mNeedsRedraw = NO;
    }
}

#pragma mark - Day/Night Cycle
- (void)updateDaylightTint
{
    /*  We tint the sky into daylight or night not by changing the Hue but by the Value and then converting the HSV
     to RGB and using the result as the new color for that vertex of the quad.  It should preserve the color but
     darken the effect accordingly.
     */
    float h = 0, s = 0, v = 0;
    int r = 0, g = 0, b = 0;
    
    ccColor4B currentSkyColor;
    ccColor4B currentHorizonColor;
    
    if (self.isOvercast)
    {
        currentSkyColor = kSkyColorStorm;
        currentHorizonColor = kHorizonColorStorm;
    }
    else
    {
        currentSkyColor = kSkyColorDaylight;
        currentHorizonColor = kHorizonColorDaylight;
    }
    
    // Change gradient-top color
    rgb_to_hsv(currentSkyColor.r, currentSkyColor.g, currentSkyColor.b, &h, &s, &v);
    v = (float)mDaylightTintValue / 255;
    if (self.isOvercast)
    {
        v = [self clampTintValue:v];
    }
    hsv_to_rgb(h, s, v, &r, &g, &b);
    [self setStartColor:ccc3(r, g, b)];
    
    // Change gradient-bottom color
    rgb_to_hsv(currentHorizonColor.r, currentHorizonColor.g, currentHorizonColor.b, &h, &s, &v);
    v = (float)mDaylightTintValue / 255;
    if (self.isOvercast)
    {
        v = [self clampTintValue:v];
    }
    hsv_to_rgb(h, s, v, &r, &g, &b);
    [self setEndColor:ccc3(r, g, b)];
}

- (float)clampTintValue:(float)v
{
    v = (v < kMinOvercastTintValue) ? kMinOvercastTintValue : v;
    v = (v > kMaxOvercastTintValue) ? kMaxOvercastTintValue : v;
    return v;
}

@end
