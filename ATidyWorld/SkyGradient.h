//
//  SkyGradient.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/** Displays a coloured gradient representing the sky. This object only performs an update call when the 
 *  {@link SkyLayer} object calculates an update in the daylight tint value.
 *  Manipulation of the daylight tint is done by changing the Value component of the HSV value for the gradient.
 *  Changing the Value (V) component changes the presence of the color; a value of 0 is black, a value of 255 is
 *  full-presence color - in the case of the sky gradient this is blue.
 */
@interface SkyGradient : CCLayerGradient
{
    @private
    BOOL                mOvercast;
    BOOL                mNeedsRedraw;
    GLubyte             mDaylightTintValue;
}

- (BOOL)isOvercast;
- (void)setOvercast:(BOOL)overcast;

/** Sets the daylight tint value used when the sky is drawn. 
 *  @param tintValue value for the daylight tint ranging from 0-255 
 */
- (void)setDaylightTintValue:(GLubyte)tintValue;

@end
