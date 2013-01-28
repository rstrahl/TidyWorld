//
//  ClockLayer.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-01-27.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ClockLayer.h"
#import "ClockFaceView.h"

@implementation ClockLayer

@synthesize clockFaceView = mClockFaceView;

- (id)init
{
    if (self = [super init])
    {
    // Add Clock Label
        mClockFaceView = [[ClockFaceView alloc] initWithFrame:CGRectZero];
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGRect clockFaceFrame = CGRectMake((screenBounds.size.width / 2) - (300 / 2),
                                           0,
                                           300,
                                           80);
        mClockFaceView.frame = clockFaceFrame;
        DLog(@"Clock width: %f", mClockFaceView.frame.size.width);
        [[[CCDirector sharedDirector] view] addSubview:mClockFaceView];
    }
    return self;
}

- (NSTimeInterval)getClockTime
{
    return [self.clockFaceView getClockTime];
}

- (void)setClockTime:(NSTimeInterval)clockTime
{
    [self.clockFaceView setClockTime:clockTime];    
}

@end
