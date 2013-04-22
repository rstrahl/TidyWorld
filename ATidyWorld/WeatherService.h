//
//  WeatherService.h
//  A Tidy World
//
//  Created by Rudi Strahl on 11-12-19.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum
{
//    WeatherCategorySeason,
    WeatherCategoryClouds,
    WeatherCategoryRain,
    WeatherCategorySnow,
    WeatherCategoryLightning,
    WeatherCategoryFog,
    WeatherCategoryTemperature
} WeatherCategory;

typedef enum
{
    WeatherSeasonSummer,
    WeatherSeasonFall,
    WeatherSeasonWinter,
    WeatherSeasonSpring
} WeatherConditionSeason;

typedef enum
{
    WeatherCloudsNone       = 0,
    WeatherCloudsPartial    = 1,
    WeatherCloudsMostly     = 2,
    WeatherCloudsOvercast   = 3
} WeatherConditionClouds;

typedef enum
{
    WeatherFogNone          = 0,
    WeatherFog              = 1
} WeatherConditionFog;

typedef enum
{
    WeatherRainNone         = 0,
    WeatherRainLight        = 1,
    WeatherRainMedium       = 2,
    WeatherRainHeavy        = 3
} WeatherConditionRain;

typedef enum
{
    WeatherSnowNone         = 0,
    WeatherSnowLight        = 1,
    WeatherSnowMedium       = 2,
    WeatherSnowBlowing      = 3,
    WeatherSnowBlizzard     = 4
} WeatherConditionSnow;

typedef enum
{
    WeatherLightningNone    = 0,
    WeatherLightning        = 1
} WeatherConditionLightning;

typedef struct
{
    WeatherConditionClouds      clouds;
    WeatherConditionFog         fog;
    WeatherConditionRain        rain;
    WeatherConditionSnow        snow;
    WeatherConditionLightning   lightning;
    WeatherConditionSeason      season;
} WeatherCondition;

/** A singleton class that manages weather data retrieved from Yahoo! Weather Service (YWS). For data to be retrieved,
    a location must be specified to the YWS using their location identifier known as "WOEID".  The Reachability class
    determines whether the YWS is accessible, enabling this class to gracefully respond to weather data requests 
    while YWS is unavailable.
    The YWS returns a weather code defined <a href="http://developer.yahoo.com/weather/#codes">here</a>. This code is parsed
    into a WeatherCondition struct and stored for reference by consumer objects.
    {@see LocationService}
    {@see Reachability}
 */
@interface WeatherService : NSObject <UIAlertViewDelegate, NSURLConnectionDelegate, NSXMLParserDelegate>
{
    NSURL                   *mWeatherServiceURL;
    BOOL                    mUseCelsius;
    BOOL                    mWeatherFeedValid;
    BOOL                    mInternetReachable;

    NSString                *mWeatherServiceString;
    
    NSString                *mConditionText;
    NSNumber                *mConditionTemp;
    NSNumber                *mConditionCode;
    NSString                *mAstronomySunrise;
    NSString                *mAstronomySunset;
    NSTimeInterval          mSunriseInSeconds;
    NSTimeInterval          mSunsetInSeconds;
    NSString                *mWindChill;
    NSString                *mWindDirection;
    NSString                *mWindPressure;
    NSString                *mWindSpeed;
    NSNumber                *mAtmosphereHumidity;
    NSNumber                *mAtmosphereVisibility;
    NSNumber                *mAtmospherePressure;
    NSNumber                *mAtmosphereRising;
    NSDate                  *mLastUpdateTime;
    WeatherCondition        mWeatherCode;
    NSTimeInterval                              mLastLocationUpdateTime;
    id __unsafe_unretained  mDelegate;
    NSInteger               mWeatherUpdateCount;
}

@property (nonatomic, unsafe_unretained) id         delegate;
@property (nonatomic, strong) NSString              *conditionText;
@property (nonatomic, strong) NSNumber              *conditionTemp;
@property (nonatomic, strong) NSNumber              *conditionCode;
@property (nonatomic, strong) NSString              *astronomySunrise;
@property (nonatomic, strong) NSString              *astronomySunset;
@property (nonatomic, assign) NSTimeInterval        sunriseInSeconds;
@property (nonatomic, assign) NSTimeInterval        sunsetInSeconds;
@property (nonatomic, strong) NSString              *windChill;
@property (nonatomic, strong) NSString              *windDirection;
@property (nonatomic, strong) NSString              *windPressure;
@property (nonatomic, strong) NSString              *windSpeed;
@property (nonatomic, strong) NSNumber              *atmosphereHumidity;
@property (nonatomic, strong) NSNumber              *atmosphereVisibility;
@property (nonatomic, strong) NSNumber              *atmospherePressure;
@property (nonatomic, strong) NSNumber              *atmosphereRising;
@property (nonatomic, strong) NSDate                *lastUpdateTime;
@property (nonatomic, assign) WeatherCondition      weatherCode;
@property (nonatomic, assign, getter = isInternetReachable) BOOL internetReachable;
@property (nonatomic, assign) NSInteger             weatherUpdateCount;

/// Returns a reference to the singleton instance
+ (WeatherService *)sharedInstance;

/// Polls the weather service for an update to the weather conditions
- (void)checkForWeatherUpdate;

/// Checks if the temperature is below the freezing point of water
- (BOOL)isSubZero;

- (void)setTemperature:(float)temperature;

- (WeatherCondition)weatherConditionsFromUserDefaults:(NSUserDefaults *)userDefaults;

@end