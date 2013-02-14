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
#import "SkyLayer.h"
#import "TMTimeUtils.h"

@interface SummerBaseLayer()
/** Initializes the variables needed for calculating day/night cycle effects. Should be called whenever weather updates
    are triggered */
- (void)initDayNightCycleWithWeatherService:(WeatherService *)weatherService;
/** Calculates the color tinting for all sprites based on the time of day 
    @param time the time in seconds within the span of a single day */
- (void)updateDayNightCycleForTime:(NSTimeInterval)time;
/** Notification Listener for Location Service 
    @param notification the originating notification object */
- (void)didReceiveLocationSuccessNotification:(NSNotification *)notification;
/** Notification Listener for Weather Service 
    @param notification the originating notification object */
- (void)didReceiveWeatherSuccessNotification:(NSNotification *)notification;
/** Notification Listener for change in Settings
    @param notification the originating notification object */
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
        [self initDayNightCycleWithWeatherService:[WeatherService sharedInstance]];
        mLastDaylightTintValue = -1;
        mLastSunriseProgress = 0;
        mLastSunsetProgress = 0;
        
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
        
        mSkyLayer = [[SkyLayer alloc] init];
        [self addChild:mSkyLayer];
        
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
    [self updateDayNightCycleForTime:[TMTimeUtils timeInDayForTimeIntervalSinceReferenceDate:(mClockTime + [[NSTimeZone localTimeZone] secondsFromGMT])]];
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
    [self initDayNightCycleWithWeatherService:weatherService];
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

#pragma mark - Day/Night Cycle
- (void)initDayNightCycleWithWeatherService:(WeatherService *)weatherService
{
    mTimeOfSunriseInSeconds = [weatherService sunriseInSeconds];
    mTimeOfSunsetInSeconds  = [weatherService sunsetInSeconds];
    mDaylightDuration       = mTimeOfSunsetInSeconds - mTimeOfSunriseInSeconds;
    mSunriseDuration        = mDaylightDuration * 0.15;
    mSunsetDuration         = mDaylightDuration * 0.15;
    mSunriseEffectStartTime = mTimeOfSunriseInSeconds - (mSunriseDuration / 2);
    mSunriseGlowStartTime   = mTimeOfSunriseInSeconds - (mSunriseDuration / 4);
    mSunsetEffectStartTime  = mTimeOfSunsetInSeconds - (mSunsetDuration / 4);
    mSunsetGlowStartTime    = mTimeOfSunsetInSeconds - (mSunsetDuration / 2);
}

- (void)updateDayNightCycleForTime:(NSTimeInterval)time
{
    // Only ever process the cycle if there is actual daylight time
    if (mDaylightDuration > 0)
    {
        // There should be two layers: one for the base sky colour (day/night) one for sunrise/sunset glows
        
        /*  All objects should be given a daylightTint - ranges from 0-255 based on the time of day. (255 due to how RGB is handled)
             The sky should start to lighten a period of time before sunrise (a factor of daylight duration).
             The sky should be fully bright shortly after the sunrise is finished.
             The sky should start to darken shortly after sunset (another factor of daylight duration).
             The sky should be fully dark shortly after the sunset is finished.
             
             The ideal sunrise/sunset should work as follows:
             Sunrise colour should start Reddish-Orange and alpha moves from 0 to 1, over the sunrise period change to Yellow-white, then fade Alpha to 0
             
             Sunset should be the reverse of this.
             The future enhancement would be to add variety to how red/orange the sunset starts
         */
        
        int daylightTintValue = 0;
        float sunriseProgress = 0;
        float sunsetProgress = 0;
        
        /*  Apply sunrise/sunset effect
            If the current time of day is between during the window of daylight hours, we will need to run 
            checks for the sunrise and sunset effects
         */
        if (time > mSunriseEffectStartTime)
        {
            daylightTintValue = ((time - mSunriseEffectStartTime) / mSunriseDuration) * 255;
            daylightTintValue = daylightTintValue > 255 ? 255 : daylightTintValue;
            daylightTintValue = daylightTintValue < 0 ? 0 : daylightTintValue;
            
            /*  If the current time is between the start time of sunrise OR sunset and its calculated end time or render the corresponding effect
             */
            if (time > mSunriseGlowStartTime &&
                time < (mSunriseGlowStartTime + mSunriseDuration))
            {
                sunriseProgress = ((time - mSunriseGlowStartTime) / mSunriseDuration);
                
            }
            else if (time > mSunsetGlowStartTime &&
                     time < (mSunsetGlowStartTime + mSunsetDuration))
            {
                sunsetProgress = ((time - mSunsetGlowStartTime) / mSunsetDuration);
            }
            
            /*  If the current time is after the sunset has started, begin to fade out the sky colours
             */
            if (time > mTimeOfSunsetInSeconds)
            {
                daylightTintValue = (1 - ((time - mTimeOfSunsetInSeconds) / mSunsetDuration)) * 255;
                daylightTintValue = daylightTintValue > 255 ? 255 : daylightTintValue;
                daylightTintValue = daylightTintValue < 0 ? 0 : daylightTintValue;
            }
        }
        
        /*  Only send out day/night cycle updates to managers if there is a "visible" difference from the last clock tick -
         because we rely on 255 values for RGB we need 1/255 threshold for visible difference.
         */
        if (abs(daylightTintValue - mLastDaylightTintValue) >= 1)
        {
            mLastDaylightTintValue = daylightTintValue;
            // TODO: update the daylightTint of all layers
            [mSkyLayer updateDaylightTint:daylightTintValue];
//            [mLandscapeManager setDaylightTint:daylightTintValue];
//            [mWeatherManager setDaylightTint:daylightTintValue];
        }
        
        // Send out the tint for sunrise
        if (fabsf(sunriseProgress - mLastSunriseProgress) >= 0.01)
        {
            mLastSunriseProgress = sunriseProgress;
            // TODO: Update sunrise progress in skyLayer
//            [self.skyManager renderDawnForProgress:sunriseProgress];
            [mSkyLayer updateSunriseProgress:sunriseProgress];
        }
        // Send out the tint for sunset
        if (fabsf(sunsetProgress - mLastSunsetProgress) >= 0.01)
        {
            mLastSunsetProgress = sunsetProgress;
            // TODO: Update sunset progress in skyLayer
            [mSkyLayer updateSunsetProgress:sunsetProgress];
        }
    }
}

@end
