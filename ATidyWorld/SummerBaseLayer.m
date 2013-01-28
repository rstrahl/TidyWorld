//
//  SummerBaseLayer.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-01-27.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SummerBaseLayer.h"
#import "ClockLayer.h"

@implementation SummerBaseLayer

// Helper class method that creates a Scene with the SummerBaseLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SummerBaseLayer *layer = [SummerBaseLayer node];
	
	// add layer as a child to scene
	[scene addChild:layer];
    
	// return the scene
	return scene;
}

- (id)init
{
    if (self = [super init])
    {
        [self scheduleUpdate];
        self.clockLayer = [ClockLayer node];
        [self addChild:self.clockLayer];
    }
    return self;
}


- (void)update:(ccTime)deltaTime
{
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    
    // Need to detect when the value of time rolls over the 1s place
    if ((time - clockTime) > 1)
    {
        clockTime = floor(time);
        DLog(@"Current time: %f", clockTime);
        [self.clockLayer setClockTime:clockTime];
    }
    
}

@end
