//
//  WeatherService.h
//  A Tidy World
//
//  Created by Rudi Strahl on 11-12-19.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/*
 WeatherCode Bitmask:
 
  00000000000
   |   | |`--Clouds
    `   ` `--Fog
     `   `---Rain
      `------Snow
 */

#define WEATHER_BITMASK_OFFSET_CLOUDS       0
#define WEATHER_BITMASK_OFFSET_FOG          3
#define WEATHER_BITMASK_OFFSET_RAIN         4
#define WEATHER_BITMASK_OFFSET_SNOW         6
#define WEATHER_BITMASK_OFFSET_LIGHTNING    9
#define WEATHER_CLOUDS_TYPE_MAX             3
#define WEATHER_FOG_TYPE_MAX                1
#define WEATHER_RAIN_TYPE_MAX               3
#define WEATHER_SNOW_TYPE_MAX               4
#define WEATHER_LIGHTNING_TYPE_MAX          1

typedef enum
{
    WeatherCategorySeason,
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
    WeatherSeasonWinter
} WeatherSeason;

typedef enum {
    WeatherCloudsNone       = 0,
    WeatherCloudsPartial    = 1,
    WeatherCloudsMostly     = 2,
    WeatherCloudsOvercast   = 3,
    
    WeatherFogNone          = 0 << WEATHER_BITMASK_OFFSET_FOG,
    WeatherFog              = 1 << WEATHER_BITMASK_OFFSET_FOG,
    
    WeatherRainNone         = 0 << WEATHER_BITMASK_OFFSET_RAIN,
    WeatherRainLight        = 1 << WEATHER_BITMASK_OFFSET_RAIN,
    WeatherRainMedium       = 2 << WEATHER_BITMASK_OFFSET_RAIN,
    WeatherRainHeavy        = 3 << WEATHER_BITMASK_OFFSET_RAIN,
    
    WeatherSnowNone         = 0 << WEATHER_BITMASK_OFFSET_SNOW,
    WeatherSnowLight        = 1 << WEATHER_BITMASK_OFFSET_SNOW,
    WeatherSnowMedium       = 2 << WEATHER_BITMASK_OFFSET_SNOW,
    WeatherSnowBlizzard        = 3 << WEATHER_BITMASK_OFFSET_SNOW,
    WeatherSnowBlowing      = 4 << WEATHER_BITMASK_OFFSET_SNOW,
    
    WeatherLightningNone    = 0 << WEATHER_BITMASK_OFFSET_LIGHTNING,
    WeatherLightning        = 1 << WEATHER_BITMASK_OFFSET_LIGHTNING
} WeatherServiceCode;

@interface WeatherService : NSObject <UIAlertViewDelegate, NSURLConnectionDelegate, NSXMLParserDelegate>
{
    NSMutableData *responseData;
    NSURL *weatherServiceURL;
    BOOL useCelsius;
    BOOL mWeatherFeedValid;
    BOOL mInternetReachable;

    NSString *weatherServiceString;
    
    NSString *conditionText;
    NSNumber *conditionTemp;
    NSNumber *conditionCode;
    NSString *astronomySunrise;
    uint mSunriseInSeconds;
    NSString *astronomySunset;
    uint mSunsetInSeconds;
    NSString *windChill;
    NSString *windDirection;
    NSString *windPressure;
    NSString *windSpeed;
    NSNumber *atmosphereHumidity;
    NSNumber *atmosphereVisibility;
    NSNumber *atmospherePressure;
    NSNumber *atmosphereRising;    
    WeatherServiceCode mWeatherCode;
    
    id __unsafe_unretained delegate;
}

@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, strong) NSString *conditionText;
@property (nonatomic, strong) NSNumber *conditionTemp;
@property (nonatomic, strong) NSNumber *conditionCode;
@property (nonatomic, strong) NSString *astronomySunrise;
@property (nonatomic, strong) NSString *astronomySunset;
@property (nonatomic, assign) uint sunriseInSeconds;
@property (nonatomic, assign) uint sunsetInSeconds;
@property (nonatomic, strong) NSString *windChill;
@property (nonatomic, strong) NSString *windDirection;
@property (nonatomic, strong) NSString *windPressure;
@property (nonatomic, strong) NSString *windSpeed;
@property (nonatomic, strong) NSNumber *atmosphereHumidity;
@property (nonatomic, strong) NSNumber *atmosphereVisibility;
@property (nonatomic, strong) NSNumber *atmospherePressure;
@property (nonatomic, strong) NSNumber *atmosphereRising;
@property (nonatomic, assign) WeatherServiceCode weatherCode;
@property (nonatomic, assign, getter = isInternetReachable) BOOL internetReachable;

+ (WeatherService *)sharedWeatherService;

- (void)didReceiveSettingsChangedNotification:(NSNotification *)notification;
- (void)didReceiveLocationUpdateNotification:(NSNotification *)notification;
- (void)willSendWeatherSuccessNotification;
- (void)willSendWeatherFailedNotification;
- (void)getWeatherFeedForWOEID:(NSNumber *)woeid;
- (BOOL)isSubZero;
- (void)setTemperature:(float)temperature;

@end