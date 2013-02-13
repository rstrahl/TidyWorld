//
//  SkyLayer.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-12.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SkyLayer : CCLayer
{
    CCLayerGradient     *mSkyBase;
    CCSprite            *mSun;
    CCSprite            *mMoon;
    // TODO: Add stars
    
    
    // Sky Colors
    ccColor4B           mSkyColorDaylight;
    ccColor4B           mHorizonColorDaylight;
    ccColor4B           mSkyColorStorm;
    ccColor4B           mHorizonColorStorm;
}

- (void)setDaylightTint:(int)tintValue;

@end
