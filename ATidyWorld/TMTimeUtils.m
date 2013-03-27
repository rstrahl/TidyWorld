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

@end
