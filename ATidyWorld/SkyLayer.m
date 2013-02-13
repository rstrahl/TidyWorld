//
//  SkyLayer.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-12.
//  Copyright 2013 Rudi Strahl. All rights reserved.
//

#import "SkyLayer.h"
#import "ColorConverter.h"

@implementation SkyLayer

- (id)init
{
    if (self = [super init])
    {
        [self scheduleUpdate];
        mSkyColorStorm        = ccc4(153, 153, 153, 255);
        mHorizonColorStorm    = ccc4(153, 153, 153, 255);
        
        // Day/Night Colors
        mSkyColorDaylight     = ccc4(0, 142, 255, 255);
        mHorizonColorDaylight = ccc4(218, 234, 255, 255);

        mSkyBase = [[CCLayerGradient alloc] initWithColor:mSkyColorDaylight fadingTo:mHorizonColorDaylight];
        DLog(@"Sky size: %f x %f", mSkyBase.contentSize.width, mSkyBase.contentSize.height);
        [self addChild:mSkyBase];

    }
    return self;
}

- (void)update:(ccTime)deltaTime
{
    
}

#pragma mark - Sprite Manipulation
//- (void)renderGlowEffect:(SkyGlowTransition)transition forProgress:(float)progress
//{
//    /*  Rather than pass in the current time, pass in a 0..1 value for "completion" percentage of dawn or dusk.
//     Set the alpha of the sunrise/sunset glow from 0..1 during the first half.
//     Set the alpha of the sunrise/sunset glow from 1..0 for the second half.
//     */
//    float alpha = 1.0f;
//    if (progress < 0.5)
//    {
//        alpha = progress / 0.5;
//    }
//    else
//    {
//        alpha = 1 - ((progress - 0.5) / 0.5);
//    }
//    mSkyGlow.alpha = alpha;
//    DLog(@"Alpha changed to %f", alpha);
//    
//    /*  Cycle the hue from 0 (Red) to Yellow (60) as we make progress
//     */
//    int hue = 0;
//    if (transition == SkyGlowTransitionOrangeToYellow)
//    {
//        hue = 10 + (progress * 50);
//    }
//    else
//    {
//        hue = 60 - (progress * 50);
//    }
//    [self setGlowTint:hue];
//}

#pragma mark - Sky Effects
//- (void)setGlowTint:(int)hueValue
//{
//    /*  We change the hue of the glow in the sky from whatever it was, retaining the saturation and value.
//     */
//    float h = 0, s = 0, v = 0;
//    int r = 0, g = 0, b = 0;
//    int newColor = 0;
//    for (int i = 0; i < 4; i++)
//    {
//        h = hueValue;
//        s = 1;
//        v = 1;
//        DLog(@"AFTER:  H = %f, S = %f, V = %f", h, s, v);
//        hsv_to_rgb(h, s, v, &r, &g, &b);
//        DLog(@"AFTER:  R = %d, G = %d, B = %d", r, g, b);
//        newColor = rgb_to_int(r, g, b);
//        [mSkyGlow setColor:newColor ofVertex:i];
//    }
//}

#pragma mark - Day/Night Cycle
- (void)setDaylightTint:(int)tintValue
{
    /*  We tint the sky into daylight or night not by changing the Hue but by the Value and then converting the HSV
     to RGB and using the result as the new color for that vertex of the quad.  It should preserve the color but
     darken the effect accordingly.
     */
    float h = 0, s = 0, v = 0;
    int r = 0, g = 0, b = 0;
    
    // Change gradient-top color
    rgb_to_hsv(mSkyColorDaylight.r, mSkyColorDaylight.g, mSkyColorDaylight.b, &h, &s, &v);
    v = (float)tintValue / 255;
    hsv_to_rgb(h, s, v, &r, &g, &b);
    [mSkyBase setStartColor:ccc3(r, g, b)];

    // Change gradient-bottom color
    rgb_to_hsv(mHorizonColorDaylight.r, mHorizonColorDaylight.g, mHorizonColorDaylight.b, &h, &s, &v);
    v = (float)tintValue / 255;
    hsv_to_rgb(h, s, v, &r, &g, &b);
    [mSkyBase setEndColor:ccc3(r, g, b)];
    
    // TODO: Set the color changes for storm skies
//    if (mStormBackgroundSprite.numChildren > 0)
//    {
//        [self setStormBackgroundTintValue:tintValue];
//    }
//
    // TODO: Set the alpha for objects like stars (or remove them?)
//    [self setNightObjectsAlpha:(1 - ((float)tintValue / 255))];
}

//- (void)setStormBackgroundTintValue:(int)tintValue
//{
//    float h = 0, s = 0, v = 0;
//    int r = 0, g = 0, b = 0;
//    int newColor = 0;
//    v = (float)tintValue / 255;
//    v = (v < kMinDaytimeTintValue) ? kMinDaytimeTintValue : v;
//    if (mGameDelegate.isOvercast)
//    {
//        v = (v > TINT_OVERCAST_MAX_VALUE) ? TINT_OVERCAST_MAX_VALUE : v;
//    }
//    //    DLog(@"AFTER:  H = %f, S = %f, V = %f", h, s, v);
//    hsv_to_rgb(h, s, v, &r, &g, &b);
//    //    DLog(@"AFTER:  R = %d, G = %d, B = %d", r, g, b);
//    newColor = rgb_to_int(r, g, b);
//    SPQuad *stormQuad = (SPQuad *)[mStormBackgroundSprite childAtIndex:0];
//    [stormQuad setColor:newColor];
//}


@end
