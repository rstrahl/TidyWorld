//
//  SummerBaseLayer.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-01-27.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SummerBaseLayer.h"
#import "ClockFaceView.h"
#import "AdsViewController.h"
#import "Constants.h"
#import "WeatherService.h"
#import "LocationService.h"
#import "SettingsTableViewController.h"
#import "ButtonsViewController.h"

@interface SummerBaseLayer()
/** Notification Listener for Location Service */
- (void)didReceiveLocationSuccessNotification:(NSNotification *)notification;
/** Notification Listener for Weather Service */
- (void)didReceiveWeatherSuccessNotification:(NSNotification *)notification;
@end

@implementation SummerBaseLayer

@synthesize clockFaceView = mClockFaceView,
            adsViewController = mAdsViewController,
            buttonsViewController = mButtonsViewController;

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
        
        // Add Clock Label
        CGSize screenSize = [[CCDirector sharedDirector] view].frame.size;
        mClockFaceView = [[ClockFaceView alloc] initWithFrame:CGRectZero];
        CGRect clockFaceFrame = CGRectMake((screenSize.width / 2) - (300 / 2),
                                           0,
                                           300,
                                           80);
        mClockFaceView.frame = clockFaceFrame;
        DLog(@"Clock width: %f", mClockFaceView.frame.size.width);
        [[[CCDirector sharedDirector] view] addSubview:mClockFaceView];
        
        // Add AdsViewController
        mAdsViewController = [[AdsViewController alloc] initWithNibName:nil bundle:nil];
        [[[CCDirector sharedDirector] view] addSubview:mAdsViewController.view];
        
        // Add ButtonsViewControlller
        mButtonsViewController = [[ButtonsViewController alloc] initWithNibName:nil bundle:nil];
        [[[CCDirector sharedDirector] view] addSubview:mButtonsViewController.view];
        
        // Register notification listeners for service
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveLocationSuccessNotification:)
                                                     name:NOTIFICATION_LOCATION_SUCCESS
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveWeatherSuccessNotification:)
                                                     name:NOTIFICATION_WEATHER_SUCCESS
                                                   object:nil];
        [[LocationService sharedInstance] startServiceTimer];
    }
    return self;
}

- (void)update:(ccTime)deltaTime
{
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    
    // Detect increments of one second and update the clock face accordingly
    if ((time - mClockTime) > 1)
    {
        mClockTime = floor(time);
        DLog(@"Current time: %f", mClockTime);
        [self.clockFaceView setClockTime:mClockTime];
    }
}

#pragma mark - Notifications
- (void)didReceiveLocationSuccessNotification:(NSNotification *)notification
{
    LocationService *locationService = [LocationService sharedInstance];
    NSString *locationString = [NSString stringWithFormat:@"%@, %@, %@", locationService.city, locationService.state, locationService.country];
    [self.clockFaceView setLocation:locationString];
}

- (void)didReceiveWeatherSuccessNotification:(NSNotification *)notification
{
    WeatherService *weatherService = [WeatherService sharedInstance];
    [self.clockFaceView setTemperature:[weatherService.conditionTemp floatValue]];
}

@end
