//
//  SkyDawnDuskGradient.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "DawnDuskGradient.h"
#import "ColorConverter.h"

const ccColor4B kSkyColorDusk           = {255, 255, 255, 0};
const ccColor4B kHorizonColorDusk       = {255, 255, 255, 0};
const ccColor4B kSkyColorDawn           = {255, 255, 255, 0};
const ccColor4B kHorizonColorDawn       = {255, 255, 255, 0};

// Private Interface
@interface DawnDuskGradient()
/** Updates the opacity of the sky effect, if the progress value has changed 
 */
- (void)updateEffectOpacity;
/** Updates the hue of the sky effect, if the progress value has changed 
 */
- (void)updateEffectHue;
@end
// -----------------------------

@implementation DawnDuskGradient

@synthesize skyEffectType = mSkyEffectType;

- (id)init
{
    if (self = [super initWithColor:kSkyColorDawn fadingTo:kHorizonColorDawn])
    {
        [self scheduleUpdate];
//        [self setBlendFunc:(ccBlendFunc){GL_ONE, GL_ZERO}];
        mSkyEffectType = SkyEffectTypeDawn;
    }
    return self;
}

- (void)update:(ccTime)deltaTime
{
    if (mNeedsRedraw)
    {
        [self updateEffectOpacity];
        [self updateEffectHue];
        mNeedsRedraw = NO;
    }
}

- (void)setEffectProgress:(float)progress forEffectType:(SkyEffectType)type
{
    mEffectProgress = progress;
    mSkyEffectType = type;
    mNeedsRedraw = YES;
}

#pragma mark Dusk/Dawn Effect
- (void)updateEffectOpacity
{
    /*  Rather than pass in the current time, pass in a 0..1 value for "completion" percentage of dawn or dusk.
     *  Set the alpha of the sunrise/sunset glow from 0..1 during the first half.
     *  Set the alpha of the sunrise/sunset glow from 1..0 for the second half.
     */
    GLubyte alpha = 255;
    
    if (mEffectProgress < 0.3)
    {
        // As progress -> 0.5, alpha -> 255
        alpha = (mEffectProgress / 0.3) * 255;
        if (alpha < 1)
        {
            [self setVisible:NO];
        }
        else if (self.visible == NO)
        {
            [self setVisible:YES];
        }
    }
    else if (mEffectProgress > 0.7)
    {
        // As progress <- 0.5, alpha -> 0
        alpha = 255 - (((mEffectProgress - 0.7)/ 0.3) * 255);
        
    }
    [self setEndOpacity:alpha];
    }

- (void)updateEffectHue
{
    /*  Cycle the hue from 0 (Red) to Yellow (60) as we make progress
     */
    int hue = 0;
    if (mSkyEffectType == SkyEffectTypeDawn) // Red to Yellow (Dawn)
    {
        hue = 20 + (mEffectProgress * 40);
    }
    else // Yellow to Red (Dusk)
    {
        hue = 60 - (mEffectProgress * 40);
    }

    int r = 0, g = 0, b = 0;
    // We need RGB format
    hsv_to_rgb(hue, 1, 1, &r, &g, &b);
    [self setEndColor:ccc3(r, g, b)];
}

@end
