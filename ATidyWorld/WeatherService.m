//
//  WeatherService.m
//  A Tidy World
//
//  Created by Rudi Strahl on 11-12-19.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WeatherService.h"
#import "ClockConstants.h"
#import "LocationService.h"
#import "Constants.h"
#import "TMTimeUtils.h"
#import "SettingsConstants.h"
#import "Reachability.h"

static WeatherService *sharedWeatherService = nil;

const NSTimeInterval kDefaultSunriseTime    = 25200.0f;
const NSTimeInterval kDefaultSunsetTime     = 68400.0f;

// Start Private Interface -------------------------------------------------------------------------------
@interface WeatherService()

- (WeatherCondition)buildWeatherCode:(NSNumber *)yahooCode;
- (void)getWeatherFeedForWOEID:(NSNumber *)woeid;

// Notifications
- (void)willSendWeatherSuccessNotification;
- (void)willSendWeatherFailedNotification;

// Analytics Methods
- (void)analyticsDidFinishLoadingSince:(NSDate *)date;

@end
// End Private Interface ---------------------------------------------------------------------------------

@implementation WeatherService

@synthesize delegate,
            conditionText = mConditionText,
            conditionCode = mConditionCode,
            conditionTemp = mConditionTemp,
            astronomySunrise = mAstronomySunrise,
            astronomySunset = mAstronomySunset,
            windChill = mWindChill,
            windDirection = mWindDirection,
            windPressure = mWindPressure,
            windSpeed = mWindSpeed,
            atmosphereHumidity = mAtmosphereHumidity,
            atmospherePressure = mAtmospherePressure,
            atmosphereRising = mAtmosphereRising,
            atmosphereVisibility = mAtmosphereVisibility,
            sunriseInSeconds = mSunriseInSeconds,
            sunsetInSeconds = mSunsetInSeconds,
            weatherCode = mWeatherCode,
            internetReachable = mInternetReachable,
            lastUpdateTime = mLastUpdateTime;

- (id)init
{
    self = [super init];
    if (self) {        
        mWeatherServiceString = kYahooWeatherServiceURL;
        mWeatherServiceURL = [NSURL URLWithString:mWeatherServiceString];
        self.sunriseInSeconds = kDefaultSunriseTime;
        self.sunsetInSeconds = kDefaultSunsetTime;
        self.conditionTemp = [NSNumber numberWithFloat:59];
        self.weatherCode = [self buildWeatherCode:[NSNumber numberWithInt:30]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveReachabilityNotification:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    }
    return self;
}


#pragma mark - Singleton
+ (WeatherService *) sharedInstance
{
    static dispatch_once_t safer;
    dispatch_once(&safer, ^{
        sharedWeatherService = [[WeatherService alloc] init];
        // private initialization goes here.
    });
    return sharedWeatherService;
}

#pragma mark - Weather Helper Methods
- (BOOL)isSubZero
{
    if ([self.conditionTemp intValue] < 32)
        return YES;
    else
        return NO;
}

- (void)setTemperature:(float)temperature
{
    self.conditionTemp = [NSNumber numberWithFloat:temperature];
    [self willSendWeatherSuccessNotification];
}

#pragma mark - Weather Feed
- (void)checkForWeatherUpdate
{
    if (self.internetReachable)
    {
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
        if ((now - mLastLocationUpdateTime) >= 120)
        {
            LocationService *locationController = [LocationService sharedInstance];
            if (locationController.woeid != nil)
            {
                mLastLocationUpdateTime = [NSDate timeIntervalSinceReferenceDate];
                NSOperationQueue *queue = [NSOperationQueue new];
                NSInvocationOperation *operation = [[NSInvocationOperation alloc]
                                                    initWithTarget:self
                                                    selector:@selector(getWeatherFeedForWOEID:)
                                                    object:locationController.woeid];
                [queue addOperation:operation];
            }
        }
        else
        {
            [self willSendWeatherUnchangedNotification];
        }
    }
    else
    {
        [self willSendWeatherFailedNotification];
    }
}

- (void)getWeatherFeedForWOEID:(NSNumber *)woeid
{
    // For performance analytics
    NSDate *startTime = [NSDate date];
    
    mWeatherFeedValid = NO;
    char units;
    if (mUseCelsius)
        units = 'c';
    else
        units = 'f';
    NSString *serviceURLString = [NSString stringWithFormat:@"%@?w=%@&u=%c", mWeatherServiceString, woeid, units];
    DLog(@"Fetching weather at URL: %@", serviceURLString);
    mWeatherServiceURL = [NSURL URLWithString:serviceURLString];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:mWeatherServiceURL options:NSDataReadingUncached error:&error];
    if (data != nil)
    {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self]; // The parser calls methods in this class
        [parser setShouldProcessNamespaces:YES]; // We don't care about namespaces
        [parser setShouldReportNamespacePrefixes:NO]; //
        [parser setShouldResolveExternalEntities:NO]; // We just want data, no other stuff
        
        if (![parser parse]) // Parse that data..
        {
            DLog(@"ERROR trying to parse xml: %@", [[parser parserError] localizedDescription]);
            mWeatherFeedValid = NO;
            [self analyticsLogWeatherError:[NSString stringWithFormat:@"Weather Feed Parse Error: %@" ,[[parser parserError] localizedDescription]]];
        }
        self.weatherCode = [self buildWeatherCode:self.conditionCode];
    }
    else
    {
        DLog(@"ERROR fetching weather data: %@", [error localizedDescription]);
        [self analyticsLogWeatherError:@"Weather service returned bad data"];
    }
    
    // Check that we have valid data from our feed
    if (mWeatherFeedValid)
    {
        if (![NSThread isMainThread])
        {
            [self performSelectorOnMainThread:@selector(willSendWeatherSuccessNotification) withObject:nil waitUntilDone:NO];
        }
        else 
        {
            [self willSendWeatherSuccessNotification];
        }
    }
    else
    {
        DLog(@"ERROR: Weather feed was invalid!");
        [self analyticsLogWeatherError:@"Weather feed active but contained bad info"];
        if (![NSThread isMainThread])
        {
            [self performSelectorOnMainThread:@selector(willSendWeatherFailedNotification) withObject:nil waitUntilDone:NO];
        }
        else
        {
            [self willSendWeatherFailedNotification];
        }
    }
    
    [self analyticsDidFinishLoadingSince:startTime];
}

#pragma mark - NSXMLParserDelegate Implementation
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"condition"])
    {
        self.conditionText = [attributeDict objectForKey:@"text"];
        self.conditionTemp = [NSNumber numberWithFloat:[[attributeDict objectForKey:@"temp"] floatValue] ];
        self.conditionCode = [NSNumber numberWithInt:[[attributeDict objectForKey:@"code"] intValue] ];
        
        if (self.conditionTemp != nil)
        {
            mWeatherFeedValid = YES;
        }
    }
    else if ([elementName isEqualToString:@"astronomy"])
    {
        self.astronomySunrise = [attributeDict objectForKey:@"sunrise"];
        self.astronomySunset = [attributeDict objectForKey:@"sunset"];
        
        if (self.astronomySunrise != nil && self.astronomySunset != nil)
        {
            mWeatherFeedValid = YES;
        }
        
        // Set values for sunrise/sunset
        NSDateFormatter *weatherTimeFormatter = [[NSDateFormatter alloc] init];
        [weatherTimeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [weatherTimeFormatter setDateFormat:@"hh:mm a"];

        NSDate *sunriseDate = [weatherTimeFormatter dateFromString:self.astronomySunrise];
        NSDate *sunsetDate = [weatherTimeFormatter dateFromString:self.astronomySunset];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:[NSDate date]];
        NSDateComponents *sunriseTimeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate: sunriseDate ];
        NSDateComponents *sunsetTimeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate: sunsetDate ];
        
        [dateComponents setHour:[sunriseTimeComponents hour]];
        [dateComponents setMinute:[sunriseTimeComponents minute]];
        [dateComponents setSecond:[sunriseTimeComponents second]];
        NSDate *sunriseTimeToday = [calendar dateFromComponents:dateComponents];
        [dateComponents setHour:[sunsetTimeComponents hour]];
        [dateComponents setMinute:[sunsetTimeComponents minute]];
        [dateComponents setSecond:[sunsetTimeComponents second]];
        NSDate *sunsetTimeToday = [calendar dateFromComponents:dateComponents];
        
        // Yahoo puts sunrise/sunset in localtime format - we deal with GMT time 
        NSInteger gmtOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
        if([[NSTimeZone localTimeZone] isDaylightSavingTime])
        {
            gmtOffset = gmtOffset - 3600;
        }
        self.sunriseInSeconds = [TMTimeUtils timeInDayForTimeIntervalSinceReferenceDate:([sunriseTimeToday timeIntervalSinceReferenceDate] + gmtOffset)];
        self.sunsetInSeconds = [TMTimeUtils timeInDayForTimeIntervalSinceReferenceDate:([sunsetTimeToday timeIntervalSinceReferenceDate] + gmtOffset)];
    }
    else if ([elementName isEqualToString:@"wind"])
    {
        self.windChill = [attributeDict objectForKey:@"chill"];
        self.windDirection = [attributeDict objectForKey:@"direction"];
        self.windSpeed = [attributeDict objectForKey:@"speed"];
    }
    else if ([elementName isEqualToString:@"atmosphere"])
    {
        self.atmosphereHumidity = [NSNumber numberWithFloat:[[attributeDict objectForKey:@"humidity"] floatValue] ];
        self.atmospherePressure = [NSNumber numberWithFloat:[[attributeDict objectForKey:@"pressure"] floatValue] ];
        self.atmosphereRising = [NSNumber numberWithFloat:[[attributeDict objectForKey:@"rising"] floatValue] ];
        self.atmosphereVisibility = [NSNumber numberWithFloat:[[attributeDict objectForKey:@"visibility"] floatValue] ];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
}

#pragma mark - Weather Code
- (WeatherCondition)buildWeatherCode:(NSNumber *)yahooCode
{
    WeatherCondition code = {0,0,0,0,0};
    switch ([yahooCode intValue]) {
//        case 0:     // Tornado
        case 3:     // Severe Thunderstorms
        case 4:     // Thunderstorms
        case 37:    // Isolated Thunderstorms
        case 38:    // Scattered Thunderstorms
        case 39:    // Scattered Thunderstorms
        case 45:    // Thundershowers
        case 47:    // Isolated Thundershowers
        {
            code.clouds = WeatherCloudsOvercast;
            code.rain = WeatherRainHeavy;
            code.lightning = WeatherLightning;
            break;
        }
        case 5:     // Mixed Rain and Snow
        case 6:     // Mixed Rain and Sleet
        case 7:     // Mixed Snow and Sleet
        case 8:     // Freezing Drizzle
        case 9:     // Drizzle
        case 10:    // Freezing Rain
        case 11:    // Showers
        case 12:    // Showers
        case 40:    // Scattered Showers
        {
            code.clouds = WeatherCloudsOvercast;
            code.rain = WeatherRainMedium;
            break;
        }

        case 13:    // Snow Flurries
        case 15:    // Blowing Snow
        {
            code.clouds = WeatherCloudsOvercast;
            code.snow = WeatherSnowBlowing;
            break;
        }
        case 14:    // Light Snow Showers
        case 16:    // Snow
        case 46:    // Snow Showers
        {
            code.clouds = WeatherCloudsOvercast;
            code.snow = WeatherSnowMedium;
            break;
        }
        case 17:    // Hail
        case 18:    // Sleet
        {
            code.clouds = WeatherCloudsOvercast;
            code.rain = WeatherRainMedium;
            break;
        }
        case 19:    // Dust
        case 20:    // Foggy
        case 21:    // Haze
        case 22:    // Smoky
        case 23:    // Blustery
        {
            code.fog = WeatherFog;
            break;
        }
        case 24:    // Windy
        case 25:    // Cold
        {
            // TODO: Finish Weather Implementation: Windy/Cold
            break;
        }
        case 26:    // Cloudy
        case 27:    // Mostly Cloudy (Night)
        case 28:    // Mostly Cloudy (Day)
        {
            code.clouds = WeatherCloudsMostly;
            break;
        }
        case 29:    // Partly Cloudy (Night)
        case 30:    // Partly Cloudy (Day)
        case 44:    // Partly Cloudy
        {
            code.clouds = WeatherCloudsPartial;
            break;
        }
        case 31:    // Clear
        case 32:    // Sunny
        {
            break;
        }
        case 33:    // Fair (Night)
        case 34:    // Fair (Day)
        {
            code.clouds = WeatherCloudsPartial;
            break;
        }
        case 35:    // Mixed Rain and Hail
        {
            code.clouds = WeatherCloudsOvercast;
            code.rain = WeatherRainMedium;
            break;
        }
        case 36:    // Hot
        {
            break;
        }
        case 41:    // Heavy Snow
        case 42:    // Scattered Snow Showers
        case 43:    // Heavy Snow
        {
            code.clouds = WeatherCloudsOvercast;
            code.snow = WeatherSnowBlizzard;
            break;
        }
        case 3200:  // Not Available
        default:
        {
            break;
        }
    }
    return code;
}

- (WeatherCondition)weatherConditionsFromUserDefaults:(NSUserDefaults *)userDefaults
{
    WeatherCondition weatherCondition;
    weatherCondition.clouds = [userDefaults integerForKey:SETTINGS_KEY_CURRENT_CLOUDS];
    weatherCondition.rain = [userDefaults integerForKey:SETTINGS_KEY_CURRENT_RAIN];
    weatherCondition.snow = [userDefaults integerForKey:SETTINGS_KEY_CURRENT_SNOW];
    weatherCondition.fog = [userDefaults boolForKey:SETTINGS_KEY_CURRENT_FOG];
    weatherCondition.lightning = [userDefaults boolForKey:SETTINGS_KEY_CURRENT_LIGHTNING];
    return weatherCondition;
}

#pragma mark - Weather Notification
- (void)willSendWeatherSuccessNotification
{
    self.lastUpdateTime = [NSDate date];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WEATHER_SUCCESS object:self];
}

- (void)willSendWeatherFailedNotification
{
    UIAlertView *weatherFeedProblemAlertView =
    [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_VIEW_WEATHER_PROBLEM_TITLE", @"Weather Feed Problem")
                               message:NSLocalizedString(@"ALERT_VIEW_WEATHER_PROBLEM_MESSAGE", @"Weather Feed Problem")
                              delegate:self
                     cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                     otherButtonTitles:nil];
    [weatherFeedProblemAlertView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WEATHER_FAILED object:self];
}

- (void)willSendWeatherUnchangedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WEATHER_UNCHANGED object:self];
}

#pragma mark - Notification Listeners
- (void)didReceiveReachabilityNotification:(NSNotification *)notification
{
    Reachability *reachable = (Reachability *)notification.object;
    self.internetReachable = reachable.isReachable;
}


#pragma mark - Analytics Methods
- (void)analyticsDidFinishLoadingSince:(NSDate *)date
{
    if (ANALYTICS)
    {
        [[GAI sharedInstance].defaultTracker trackTimingWithCategory:@"resources"
                                                           withValue:fabs([date timeIntervalSinceNow])
                                                            withName:@"WeatherLoadTime"
                                                           withLabel:@"Weather Data Load Time"];
    }
}

- (void)analyticsLogWeatherError:(NSString *)errorString
{
    if (ANALYTICS)
    {
        [[GAI sharedInstance].defaultTracker trackException:NO withDescription:errorString];
    }
}

@end
