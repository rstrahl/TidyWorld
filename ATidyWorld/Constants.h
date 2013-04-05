//
//  Constants.h
//  TidyTime
//
//  Created by Rudi Strahl on 12-07-31.
//
//

#ifndef TidyTime_Constants_h
#define TidyTime_Constants_h

#define ALARM_DEFAULT_SOUND_FILE            @"beep.mp3"
#define ALARM_DEFAULT_SOUND_NAME            @"Beep"

#define NOTIFICATION_SETTINGS_CHANGED       @"NotifySettingsUpdate"
#define NOTIFICATION_WEATHER_SUCCESS        @"NotifyWeatherUpdate"
#define NOTIFICATION_WEATHER_FAILED         @"NotifyWeatherFailed"
#define NOTIFICATION_WEATHER_UNCHANGED      @"NotifyWeatherUnchanged"
#define NOTIFICATION_LOCATION_SUCCESS       @"NotifyLocationUpdate"
#define NOTIFICATION_LOCATION_FAILED        @"NotifyLocationFailed"
#define NOTIFICATION_LOCATION_UNCHANGED     @"NotifyLocationUnchanged"
#define NOTIFICATION_ALARMS_UPDATED         @"NotifyAlarmsUpdated"

#define WEATHER_SERVICE_CHECK_TIMER         900

#define PARTICLE_FILE_RAIN_LIGHT            @"RainLight.plist"
#define PARTICLE_FILE_RAIN_MEDIUM           @"RainMedium.plist"
#define PARTICLE_FILE_RAIN_HEAVY            @"RainHeavy.plist"
#define PARTICLE_FILE_SNOW_LIGHT            @"SnowLight.plist"
#define PARTICLE_FILE_SNOW_MEDIUM           @"SnowMedium.plist"
#define PARTICLE_FILE_SNOW_HEAVY            @"SnowHeavy.plist"
#define PARTICLE_FILE_SNOW_BLIZZARD         @"SnowBlizzard.plist"
#define PARTICLE_FILE_SNOW_BLOWING          @"SnowBlowing.plist"
#define PARTICLE_FILE_STARS                 @"Stars.plist"

#define FILE_SCENERY                        @"Landscape"

extern float const kMinDaytimeTintValue;
extern float const kMinOvercastTintValue;
extern float const kMaxOvercastTintValue;
extern float const kMinLandscapeOvercastTintValue;
extern float const kMaxLandscapeOvercastTintValue;
extern float const kMaxLandscapeNightTintValue;
extern float const kMinLandscapeNightTintValue;

extern float const kTemperatureMinimumValue;
extern float const kTemperatureFreezingValue;
extern float const kTemperatureMaximumValue;

// URL Constants
extern NSString *const kYahooWeatherServiceURL;

// Filename Constants
extern NSString *const kAlarmMediaPList;
extern NSString *const kAlarmSoundEffectPList;

// SoundEffects PList Keys
extern NSString *const kSoundEffectTitleKey;
extern NSString *const kSoundEffectFilenameKey;

// UIKit Constants
extern CGFloat const kNameTableCellWidth;
extern CGFloat const kNameTableCellWidthPadding;
extern CGFloat const kNameTableCellTextFieldXPadding;
extern CGFloat const kNameTableCellTextFieldYPadding;
extern CGFloat const kNameTableCellTextFieldHeight;

// Time Constants
extern NSTimeInterval const kSnoozeIntervalInMinutes;
extern CGFloat const kLightningThreshold;

typedef enum
{
    TMClockTimeLapseNormal,
    TMClockTimeLapseFast,
    TMClockTimeLapseFaster,
    TMClockTimeLapseFastest
} TMClockTimeLapse;

// SpriteSheet Constants
#define SPRITESHEET_WEATHER_PLIST           @"WeatherSpriteSheet.plist"
#define SPRITESHEET_WEATHER_IMAGE           @"WeatherSpriteSheet.png"
#define SPRITESHEET_SKY_PLIST               @"SkySpriteSheet.plist"
#define SPRITESHEET_SKY_IMAGE               @"SkySpriteSheet.png"
#define SPRITESHEET_LANDSCAPE_PLIST         @"LandscapeSpriteSheet.plist"
#define SPRITESHEET_LANDSCAPE_IMAGE         @"LandscapeSpriteSheet.png"

extern uint const kLandscapeForegroundCount;
extern uint const kLandscapeBackgroundCount;

// Coordinate Constants
extern CGPoint const kOffscreenSpritePoint;

// Testflight
#define TESTFLIGHT_APP_ID                   @"7eb3e7c2-fe13-4fdb-8168-af4f5249cdd7"

// Advertising
#define ADMOB_PUBLISHER_ID                  @"a150de0742840ec"
#define ADMOB_SIMULATOR_IDENTIFIER1         @"C77C7F9F-63D0-5BF4-820F-7084658E8B79"
#define ADWHIRL_APP_ID                      @"55fcaa5b0ac648df91eb06e411368f0a"
#define AD_REFRESH_RATE                     60

// Google Analytics
// TODO: PRE-RELEASE CONFIG: Change analytics codes to release build
#define ANALYTICS_GOOGLE_TRACKING_ID        @"UA-36822575-3"

#endif
