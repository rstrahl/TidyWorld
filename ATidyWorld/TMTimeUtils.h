//
//  TimeUtils.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-08.
//
//

#import <Foundation/Foundation.h>

extern NSTimeInterval const kOneDayInSeconds;
extern NSTimeInterval const kOneDayInMillis;
extern NSTimeInterval const kOneHourInSeconds;
extern NSTimeInterval const kHalfHourInSeconds;

@interface TMTimeUtils : NSObject

+ (NSTimeInterval)timeIntervalOfDayStartForTimeIntervalSinceReferenceDate:(NSTimeInterval)time;
+ (NSTimeInterval)timeInDayForTimeIntervalSinceReferenceDate:(NSTimeInterval)time;
+ (NSTimeInterval)timeOffsetForLocalTimeZoneDaylightSavings;
+ (NSString *)timeStringForTimeOfDay:(NSTimeInterval)time inTimeZone:(NSTimeZone *)timeZone;
+ (NSString *)timeStringForTimeOfDay:(NSTimeInterval)time;
+ (NSTimeInterval)timeSinceReferenceDateForTimeInSecondsToday:(NSTimeInterval)time;
+ (NSDate *)dateForTimeInSecondsToday:(NSTimeInterval)time;

@end
