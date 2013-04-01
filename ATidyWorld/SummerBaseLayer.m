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
#import "ButtonTrayView.h"
#import "MainViewController.h"
#import "AlarmService.h"
#import "SettingsConstants.h"
#import "ClockConstants.h"
#import "SkyLayer.h"
#import "WeatherLayer.h"
#import "LandscapeLayer.h"
#import "TMTimeUtils.h"

@interface SummerBaseLayer()
// Layer Setup ----------------------------------------------------------------
/** Initializes the variables needed for calculating day/night cycle effects. Should be called whenever weather updates
    are triggered */
- (void)initDayNightCycleWithWeatherService:(WeatherService *)weatherService;

// Game Loop Update -----------------------------------------------------------
/** Updates the weather conditions given the data provided
 *  @param conditions the WeatherCondition struct containing current conditions data
 */
- (void)updateWeatherConditions:(WeatherCondition)conditions;
/** Calculates the color tinting for all sprites based on the time of day 
    @param time the time in seconds within the span of a single day */
- (void)updateDayNightCycleForTime:(NSTimeInterval)time;

// Notification Handlers ------------------------------------------------------
/** Notification Listener for Location Service 
    @param notification the originating notification object */
- (void)didReceiveLocationSuccessNotification:(NSNotification *)notification;
/** Notification Listener for Weather Service 
    @param notification the originating notification object */
- (void)didReceiveWeatherSuccessNotification:(NSNotification *)notification;
/** Notification Listener for change in Settings
    @param notification the originating notification object */
- (void)didReceiveSettingsChangedNotification:(NSNotification *)notification;

// User Defaults --------------------------------------------------------------
/** Updates the settings relevant to the scene from the NSUserDefaults */
- (void)loadApplicationSettings;
@end

@implementation SummerBaseLayer

@synthesize adsViewController = mAdsViewController,
            mainViewController = mMainViewController,
            spriteBatchNode = mSpriteBatchNode,
            particleBatchNode = mParticleBatchNode,
            landscapeBatchNode = mLandscapeBatchNode,
            landscapeLayer = mLandscapeLayer,
            usingTimeLapse = mUsingTimeLapse,
            usingLocationBasedWeather = mUsingLocationBasedWeather,
            overcast = mOvercast,
            currentWeatherCondition = mCurrentWeatherCondition;

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
        [self initDayNightCycleWithWeatherService:[WeatherService sharedInstance]];
        mLastDaylightTintValue = -1;
        mLastSunriseProgress = 0;
        mLastSunsetProgress = 0;
        mNight = -1;
        
        
        // Add UI Panel
        mMainViewController = [[MainViewController alloc] initWithNibName:nil bundle:nil];
        [mMainViewController setSceneDelegate:self];
        [[[CCDirector sharedDirector] view] addSubview:mMainViewController.view];
        
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

        // Init sky
        mSkyLayer = [[SkyLayer alloc] initWithSceneDelegate:self];
        // Init weather
        mWeatherLayer = [[WeatherLayer alloc] initWithSceneDelegate:self];
        // Init landscape
        mLandscapeLayer = [[LandscapeLayer alloc] initWithSceneDelegate:self];

        // Add layers in order - this only affects layers, not the sprite children (those are batched)
        [self addChild:mSkyLayer];
        [self addChild:mLandscapeLayer];
        [self addChild:mWeatherLayer];
        
        // Load scene settings from user defaults
        [self loadApplicationSettings];
    }
    return self;
}

#pragma mark - Application Settings
- (void)loadApplicationSettings
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    mUsingTimeLapse = [userDefaults boolForKey:SETTINGS_KEY_CLOCK_IS_TIME_LAPSE];
    mUsingLocationBasedWeather = [userDefaults boolForKey:SETTINGS_KEY_LOCATION_BASED_WEATHER];
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
    if (mUsingLocationBasedWeather)
    {
        // Pop an activity indicator stating weather data is loading
        // activity indicator is dismissed when weather conditions are done loading or
        //     cannot be loaded
    }
    else
    {
        WeatherCondition conditions = [[WeatherService sharedInstance] weatherConditionsFromUserDefaults:userDefaults];
        [self controller:nil didChangeWeatherConditions:conditions];        
    }
}

#pragma mark - Game Loop Update
- (void)update:(ccTime)deltaTime
{
    NSTimeInterval time;
    // If the time-lapse flag is set, process time as a delta and do not process alarms
    if (mUsingTimeLapse)
    {
        mClockTime += deltaTime * mTimeLapseMultiplier;
        [self.mainViewController.clockView setClockTime:mClockTime];
//        DLog(@"Time-lapsed current time: %f", mClockTime);
    }
    else // Process time as normal, in per-second updates to the system
    {
        time = [NSDate timeIntervalSinceReferenceDate];
        // Detect increments of one second and update the clock face accordingly
        if ((time - mClockTime) > 1)
        {
            mClockTime = floor(time);
            [self.mainViewController.clockView setClockTime:mClockTime];
            // If the mClockTime mod 60 equals 0, a minute has turned over, check the alarms
            if (((NSUInteger)mClockTime % 60) == 0)
            {
                [[AlarmService sharedInstance] updateWithTime:mClockTime];
            }
//            DLog(@"Current time: %f", mClockTime);
        }
    }
    [self updateDayNightCycleForTime:[TMTimeUtils timeInDayForTimeIntervalSinceReferenceDate:(mClockTime + [[NSTimeZone localTimeZone] secondsFromGMT])]];
}

#pragma mark - Weather Effects
- (void)updateWeatherConditions:(WeatherCondition)conditions
{
    mOvercast = (conditions.clouds == WeatherCloudsOvercast) ? YES : NO;
    [mSkyLayer setOvercast:mOvercast];
    [mWeatherLayer setOvercast:mOvercast];
    mLandscapeLayer.overcast = mOvercast;
    [mWeatherLayer setWeatherCondition:conditions];
    mCurrentWeatherCondition = conditions;
}

- (void)cloudWillFireLightningEffectWithDecay:(int)lightningDecay
{

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
        
        // Update whether or not its considered night
        BOOL nightCheck = (daylightTintValue > 128) ? NO : YES;
        if (mNight != nightCheck)
        {
            mNight = nightCheck;
            [mSkyLayer setNightTime:mNight];
        }
        
        /*  Only send out day/night cycle updates to managers if there is a "visible" difference from the last clock tick -
         because we rely on 255 values for RGB we need 1/255 threshold for visible difference.
         */
        if (abs(daylightTintValue - mLastDaylightTintValue) >= 1)
        {
            mLastDaylightTintValue = daylightTintValue;
            [mSkyLayer updateDaylightTint:daylightTintValue];
            [mWeatherLayer updateDaylightTint:daylightTintValue];
            [mLandscapeLayer updateDaylightTint:daylightTintValue];
        }
        
        // Send out the tint for sunrise
        if (fabsf(sunriseProgress - mLastSunriseProgress) >= 0.01)
        {
            mLastSunriseProgress = sunriseProgress;
            [mSkyLayer updateSunriseProgress:sunriseProgress];
        }
        // Send out the tint for sunset
        if (fabsf(sunsetProgress - mLastSunsetProgress) >= 0.01)
        {
            mLastSunsetProgress = sunsetProgress;
            [mSkyLayer updateSunsetProgress:sunsetProgress];
        }
    }
    
    // Update day/night affected children
    [mSkyLayer updateForTime:time sunriseTime:mSunriseGlowStartTime sunsetTime:mSunsetEffectStartTime];
}

#pragma mark - Notifications
- (void)didReceiveLocationSuccessNotification:(NSNotification *)notification
{
    LocationService *locationService = [LocationService sharedInstance];
    NSString *locationString = [NSString stringWithFormat:@"%@, %@, %@", locationService.city, locationService.state, locationService.country];
    DLog(@"received location: %@", locationString);
    [self.mainViewController.clockView setLocation:locationString];
}

- (void)didReceiveWeatherSuccessNotification:(NSNotification *)notification
{
    DLog(@"");
    WeatherService *weatherService = [WeatherService sharedInstance];
    [self initDayNightCycleWithWeatherService:weatherService];
    [self.mainViewController.clockView setTemperature:[weatherService.conditionTemp floatValue]];
    [self.mainViewController.clockView startTemperatureAnimationTimer];
    [self updateWeatherConditions:weatherService.weatherCode];
}

- (void)didReceiveSettingsChangedNotification:(NSNotification *)notification
{
    [self loadApplicationSettings];
}

#pragma mark - WorldOptionViewControllerDelegate Implementation
- (void)controller:(WorldOptionsViewController *)controller didChangeWeatherConditions:(WeatherCondition)condition
{
    [self updateWeatherConditions:condition];
}

- (void)controller:(WorldOptionsViewController *)controller didChangeLocationBased:(BOOL)isLocationBased
{
    mUsingLocationBasedWeather = isLocationBased;
    if (mUsingLocationBasedWeather)
    {
        [self didReceiveWeatherSuccessNotification:nil];
    }
}

- (void)controller:(WorldOptionsViewController *)controller didChangeSeason:(NSUInteger)season
{
}

@end
