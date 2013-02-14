//
//  SkyDawnDuskGradient.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
    SkyEffectTypeDawn = 0,
    SkyEffectTypeDusk = 1
} SkyEffectType;

@interface SkyDawnDuskGradient : CCLayerGradient
{
    float           mEffectProgress;
    BOOL            mNeedsRedraw;
    SkyEffectType   mSkyEffectType;
}

@property (nonatomic, assign) SkyEffectType skyEffectType;

/** Sets the progress value, causing a draw update in the Dawn/Dusk effect according to the progress 
    @param progress the value between 0 and 1 indicating the progress of the effect 
    @param type the effect type representing dawn or dusk */
- (void)setEffectProgress:(float)progress forEffectType:(SkyEffectType)type;

@end
