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
#define NOTIFICATION_LOCATION_SUCCESS       @"NotifyLocationUpdate"
#define NOTIFICATION_LOCATION_FAILED        @"NotifyLocationFailed"

#define COLOR_SKY_OVERCAST                  0x666666
#define COLOR_HORIZON_OVERCAST              0x999999

#define TINT_MINIMUM_VALUE                  0.2f
#define TINT_OVERCAST_MAX_VALUE             0.5f

#define DEFAULT_SUNRISE_TIME_IN_SECONDS     3600*6
#define DEFAULT_SUNSET_TIME_IN_SECONDS      3600*20

#define WEATHER_SERVICE_CHECK_TIMER         900

#define PARTICLE_FILE_RAIN_LIGHT            @"RainEmitterLight.pex"
#define PARTICLE_FILE_RAIN_MEDIUM           @"RainEmitterMedium.pex"
#define PARTICLE_FILE_RAIN_HEAVY            @"RainEmitterHeavy.pex"
#define PARTICLE_FILE_SNOW_LIGHT            @"SnowEmitterLight.pex"
#define PARTICLE_FILE_SNOW_MEDIUM           @"SnowEmitterMedium.pex"
#define PARTICLE_FILE_SNOW_BLIZZARD         @"SnowEmitterBlizzard.pex"
#define PARTICLE_FILE_SNOW_BLOWING          @"SnowEmitterBlowing.pex"
#define PARTICLE_FILE_LIGHTNING             @"Lightning.pex"

#define FILE_SCENERY                        @"Landscape"

extern float const kMinDaytimeTintValue;
extern float const kMinDaytimeEntityTintValue;
extern float const kMaxOvercastTintValue;

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

typedef enum
{
    TMClockTimeLapseNormal,
    TMClockTimeLapseFast,
    TMClockTimeLapseFaster,
    TMClockTimeLapseFastest
} TMClockTimeLapse;

// Advertising
#define ADMOB_PUBLISHER_ID                  @"a150de0742840ec"
#define ADMOB_SIMULATOR_IDENTIFIER1         @"C77C7F9F-63D0-5BF4-820F-7084658E8B79"
#define ADWHIRL_APP_ID                      @"55fcaa5b0ac648df91eb06e411368f0a"

// Google Analytics
// TODO: PRE-RELEASE CONFIG: Change analytics codes to release build
#define ANALYTICS_GOOGLE_TRACKING_ID        @"UA-36822575-3"
#define ANALYTICS_GOOGLE_ON                 0

#endif
