//
//  ClockLayer.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-01-27.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class ClockFaceView;

@interface ClockLayer : CCLayer
{
    ClockFaceView           *mClockFaceView;
}

@property (nonatomic, strong) ClockFaceView *clockFaceView;


/// Get the time currently displayed by the clock face.
- (NSTimeInterval)getClockTime;
/// Set the time to be displayed by the clock face.
- (void)setClockTime:(NSTimeInterval)clockTime;

@end
