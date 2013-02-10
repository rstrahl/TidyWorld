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
#import "AlarmService.h"
#import "SettingsConstants.h"
#import "ClockConstants.h"

@interface SummerBaseLayer()
/** Notification Listener for Location Service */
- (void)didReceiveLocationSuccessNotification:(NSNotification *)notification;
/** Notification Listener for Weather Service */
- (void)didReceiveWeatherSuccessNotification:(NSNotification *)notification;
/** Notification Listener for change in Settings */
- (void)didReceiveSettingsChangedNotification:(NSNotification *)notification;
/** Updates the settings relevant to the scene from the NSUserDefaults */
- (void)loadApplicationSettings;
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
        [self loadApplicationSettings];
        
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveSettingsChangedNotification:)
                                                     name:NOTIFICATION_SETTINGS_CHANGED
                                                   object:nil];
        
        [[LocationService sharedInstance] startServiceTimer];
    }
    return self;
}

- (void)update:(ccTime)deltaTime
{
    NSTimeInterval time;
    // If the time-lapse flag is set, process time as a delta and do not process alarms
    if (mIsTimeLapse)
    {
        mClockTime += deltaTime * mTimeLapseMultiplier;
        [self.clockFaceView setClockTime:mClockTime];
        DLog(@"Time-lapsed current time: %f", mClockTime);
    }
    else // Process time as normal, in per-second updates to the system
    {
        time = [NSDate timeIntervalSinceReferenceDate];
        // Detect increments of one second and update the clock face accordingly
        if ((time - mClockTime) > 1)
        {
            mClockTime = floor(time);
            [self.clockFaceView setClockTime:mClockTime];
            // If the mClockTime mod 60 equals 0, a minute has turned over, check the alarms
            if (((NSUInteger)mClockTime % 60) == 0)
            {
                [[AlarmService sharedInstance] updateWithTime:mClockTime];
            }
            DLog(@"Current time: %f", mClockTime);
        }
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

- (void)didReceiveSettingsChangedNotification:(NSNotification *)notification
{
    [self loadApplicationSettings];
}

#pragma mark - Application Settings
- (void)loadApplicationSettings
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    mIsTimeLapse = [userDefaults boolForKey:SETTINGS_KEY_CLOCK_IS_TIME_LAPSE];
    NSInteger timeLapseMultiplier = [userDefaults integerForKey:SETTINGS_KEY_CLOCK_MULTIPLIER];
    switch (timeLapseMultiplier) {
        case TMClockTimeLapseFastest:
        {
            mTimeLapseMultiplier = CLOCK_MULTIPLIER_FASTEST;
            break;
        }
        case TMClockTimeLapseFaster:
        {
            mTimeLapseMultiplier = CLOCK_MULTIPLIER_FASTER;
            break;
        }
        case TMClockTimeLapseFast:
        {
            mTimeLapseMultiplier = CLOCK_MULTIPLIER_FAST;
            break;
        }
        default: // Normal
        {
            mTimeLapseMultiplier = CLOCK_MULTIPLIER_NORMAL;
            break;
        }
    }
    mClockTime = [NSDate timeIntervalSinceReferenceDate];
}

@end
