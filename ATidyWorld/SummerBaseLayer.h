//
//  SummerBaseLayer.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-01-27.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class ClockLayer;

@interface SummerBaseLayer : CCLayer
{
    ClockLayer          *mClockLayer;
    NSTimeInterval      clockTime;
}

@property (nonatomic, strong) ClockLayer *clockLayer;

// returns a CCScene that contains the SummerBaseLayer as the only child
+(CCScene *) scene;

@end
