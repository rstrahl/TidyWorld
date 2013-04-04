//
//  TimeUtils.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-08.
//
//

#import "TMTimeUtils.h"

NSTimeInterval const kOneDayInSeconds           = 86400;
NSTimeInterval const kOneDayInMillis            = 84600000;
NSTimeInterval const kOneHourInSeconds          = 3600;
NSTimeInterval const kHalfHourInSeconds         = 1800;

@implementation TMTimeUtils

+ (NSTimeInterval)localTimeOfDayForTimeIntervalSinceReferenceDate:(NSTimeInterval)time inTimeZone:(NSTimeZone *)timeZone
{
    // calculate GMT timeInDay
    NSTimeInterval timeInDay = [TMTimeUtils timeInDayForTimeIntervalSinceReferenceDate:time];
    NSTimeInterval localTimeInDay = timeInDay + [timeZone secondsFromGMT];
    if (localTimeInDay < 0)
    {
        return (kOneDayInSeconds + localTimeInDay);
    }
    else if (localTimeInDay > kOneDayInSeconds)
    {
        return (localTimeInDay - kOneDayInSeconds);
    }
    else
    {
        return localTimeInDay;
    }
}

+ (NSTimeInterval)timeIntervalOfDayStartForTimeIntervalSinceReferenceDate:(NSTimeInterval)time
{
    return time - [TMTimeUtils timeInDayForTimeIntervalSinceReferenceDate:time];
}

+ (NSTimeInterval)timeInDayForTimeIntervalSinceReferenceDate:(NSTimeInterval)time
{
    return (NSTimeInterval)((NSUInteger)time % (NSUInteger)kOneDayInSeconds);
}

+ (NSTimeInterval)timeOffsetForLocalTimeZoneDaylightSavings
{
    return [[NSTimeZone localTimeZone] daylightSavingTimeOffset];
}

+ (NSString *)timeStringForTimeOfDay:(NSTimeInterval)time inTimeZone:(NSTimeZone *)timeZone
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"K:mm a z"];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:time]];
}

+ (NSString *)timeStringForTimeOfDay:(NSTimeInterval)time
{
    int hours = ((int)time % 86400) / 3600;
    int minutes = ((int)time % 3600) / 60;
    return [NSString stringWithFormat:@"%d:%.2d", hours, minutes];
}

+ (NSTimeInterval)timeSinceReferenceDateForTimeInSecondsToday:(NSTimeInterval)time
{
    NSInteger todayTime = (NSInteger)[NSDate timeIntervalSinceReferenceDate];
    todayTime -= todayTime % (int)kOneDayInSeconds;
    todayTime += time;
    return todayTime;
}

+ (NSDate *)dateForTimeInSecondsToday:(NSTimeInterval)time
{
    NSInteger todayTime = (NSInteger)[NSDate timeIntervalSinceReferenceDate];
    todayTime -= todayTime % (int)kOneDayInSeconds;
    todayTime += time;
    return [NSDate dateWithTimeIntervalSinceReferenceDate:todayTime];
    
}

@end
