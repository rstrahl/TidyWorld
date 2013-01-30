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

static WeatherService *sharedWeatherService = nil;

// Start Private Interface -------------------------------------------------------------------------------
@interface WeatherService()

- (WeatherServiceCode)buildWeatherCode:(NSNumber *)yahooCode;
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
            internetReachable = mInternetReachable;

- (id)init
{
    self = [super init];
    if (self) {        
        mWeatherServiceString = kYahooWeatherServiceURL;
        mWeatherServiceURL = [NSURL URLWithString:mWeatherServiceString];
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
        LocationService *locationController = [LocationService sharedInstance];
        if (locationController.woeid != nil)
        {
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
#ifdef DEBUG
    DLog(@"Fetching weather at URL: %@", serviceURLString);
#endif
    mWeatherServiceURL = [NSURL URLWithString:serviceURLString];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:mWeatherServiceURL options:NSDataReadingUncached error:&error];
    if (data != nil)
    {
        //    NSLog(@"Data length: %d", [data length]);
        //    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //    DLog(@"Finished loading weather response: \n\r %@", responseString);
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self]; // The parser calls methods in this class
        [parser setShouldProcessNamespaces:YES]; // We don't care about namespaces
        [parser setShouldReportNamespacePrefixes:NO]; //
        [parser setShouldResolveExternalEntities:NO]; // We just want data, no other stuff
        
        if (![parser parse]) // Parse that data..
        {
#ifdef DEBUG
            DLog(@"ERROR trying to parse xml: %@", [[parser parserError] localizedDescription]);
#endif
            mWeatherFeedValid = NO;
            if (ANALYTICS_GOOGLE_ON)
            {
                [[[GAI sharedInstance] defaultTracker] trackException:NO
                                                      withDescription:@"Weather Feed Parse Error: %@", [[parser parserError] localizedDescription]];
            }
        }
        self.weatherCode = [self buildWeatherCode:self.conditionCode];
    }
    else
    {
#ifdef DEBUG
        DLog(@"ERROR fetching weather data: %@", [error localizedDescription]);
#endif
        if (ANALYTICS_GOOGLE_ON)
        {
            [[[GAI sharedInstance] defaultTracker] trackException:NO withNSError:error];
        }
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
#ifdef DEBUG
        DLog(@"ERROR: Weather feed was invalid!");
#endif
        if (![NSThread isMainThread])
        {
            [self performSelectorOnMainThread:@selector(willSendWeatherFailedNotification) withObject:nil waitUntilDone:NO];
        }
        else
        {
            [self willSendWeatherFailedNotification];
        }
    }
    
    if (ANALYTICS_GOOGLE_ON)
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
        NSInteger gmtOffset = [[NSTimeZone localTimeZone] secondsFromGMT];

        if([[NSTimeZone localTimeZone] isDaylightSavingTime])
            gmtOffset = gmtOffset - 3600;
        self.sunriseInSeconds = ((uint)[sunriseDate timeIntervalSince1970] + gmtOffset) % (int)kOneDayInSeconds;
        self.sunsetInSeconds = (uint)([sunsetDate timeIntervalSince1970] + +gmtOffset)  % (int)kOneDayInSeconds;
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
- (WeatherServiceCode)buildWeatherCode:(NSNumber *)yahooCode
{
    WeatherServiceCode code = 0;
    // http://developer.yahoo.com/weather/#codes
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
            code |= WeatherCloudsOvercast;
            code |= WeatherRainHeavy;
            code |= WeatherLightning;
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
            code |= WeatherCloudsOvercast;
            code |= WeatherRainMedium;
            break;
        }

        case 13:    // Snow Flurries
        case 15:    // Blowing Snow
        {
            code |= WeatherCloudsMostly;
            code |= WeatherSnowBlowing;
            break;
        }
        case 14:    // Light Snow Showers
        case 16:    // Snow
        case 46:    // Snow Showers
        {
            code |= WeatherCloudsMostly;
            code |= WeatherSnowMedium;
            break;
        }
        case 17:    // Hail
        case 18:    // Sleet
        {
            code |= WeatherCloudsOvercast;
            code |= WeatherRainMedium;
            break;
        }
        case 19:    // Dust
        case 20:    // Foggy
        case 21:    // Haze
        case 22:    // Smoky
        case 23:    // Blustery
        {
            // TODO: Finish Weather Implementation: Fog/Haze/Smoke
            code |= WeatherFog;
            break;
        }
        case 24:    // Windy
        case 25:    // Cold
        {
            // TODO: Finish Weather Implementation: Windy/Cold
            code = 0;
            break;
        }
        case 26:    // Cloudy
        case 27:    // Mostly Cloudy (Night)
        case 28:    // Mostly Cloudy (Day)
        {
            code |= WeatherCloudsMostly;
            break;
        }
        case 29:    // Partly Cloudy (Night)
        case 30:    // Partly Cloudy (Day)
        case 44:    // Partly Cloudy
        {
            code |= WeatherCloudsPartial;
            break;
        }
        case 31:    // Clear
        case 32:    // Sunny
        case 33:    // Fair (Night)
        case 34:    // Fair (Day)
        {
            code = 0;
            break;
        }
        case 35:    // Mixed Rain and Hail
        {
            // TODO: Finish Weather Implementation: Hail
            code |= WeatherCloudsOvercast;
            code |= WeatherRainMedium;
            break;
        }
        case 36:    // Hot
        {
            code = 0;
            break;
        }
        case 41:    // Heavy Snow
        case 42:    // Scattered Snow Showers
        case 43:    // Heavy Snow
        {
            code |= WeatherCloudsOvercast;
            code |= WeatherSnowBlizzard;
            break;
        }
        case 3200:  // Not Available
        default:
        {
            code = 0;
            break;
        }
    }
    return code;
}

#pragma mark - Weather Notification
- (void)willSendWeatherSuccessNotification
{
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

#pragma mark - Analytics Methods
- (void)analyticsDidFinishLoadingSince:(NSDate *)date
{
    [[GAI sharedInstance].defaultTracker trackTimingWithCategory:@"resources"
                                                       withValue:fabs([date timeIntervalSinceNow])
                                                        withName:@"WeatherLoadTime"
                                                       withLabel:@"Weather Data Load Time"];
}

@end
