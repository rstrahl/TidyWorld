//
//  SkyGradient.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/** Displays a coloured gradient representing the sky. This object does not draw itself on every update call,
    instead only doing a draw when the {@link SkyLayer} object calculates an update in the daylight tint value.
 */
@interface SkyGradient : CCLayerGradient
{
    // Sky Colors
    ccColor4B           mSkyColorDaylight;
    ccColor4B           mHorizonColorDaylight;
    ccColor4B           mSkyColorStorm;
    ccColor4B           mHorizonColorStorm;
    BOOL                mOvercast;
    BOOL                mNeedsRedraw;
    GLubyte             mDaylightTintValue;
}

@property (nonatomic, assign, getter = isOvercast) BOOL overcast;

/** Updates the tint value for the sky, causing the sky colours to change. Colour changes are 
    done via manipulation of Value (V in HSV). */
- (void)updateDaylightTint;

- (void)setDaylightTintValue:(GLubyte)tintValue;

@end
