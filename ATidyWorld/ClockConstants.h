//
//  Constants.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-10.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CLOCK_EVENT_RESET                   @"ClockEventReset"
#define CLOCK_EVENT_TICK                    @"ClockEventTick"
#define CLOCK_EVENT_NEW_DAY                 @"ClockEventNewDay"
#define CLOCK_EVENT_SET_TIME                @"ClockEventSetTime"
#define CLOCK_EVENT_ALARM                   @"ClockEventAlarm"
#define CLOCK_EVENT_NO_ALARMS               @"ClockEventNoAlarms"
#define CLOCK_EVENT_YES_ALARMS              @"ClockEventYesAlarms"
#define CLOCK_EVENT_USERINFO_KEY_ALARM      @"KeyAlarm"

#define CLOCK_EVENT_KEY_MULTIPLIER          @"ClockEventMultiplier"
#define CLOCK_EVENT_KEY_SECONDS             @"ClockEventSeconds"
#define CLOCK_EVENT_KEY_DATE                @"ClockEventDate"

#define CLOCK_MULTIPLIER_NORMAL             1
#define CLOCK_MULTIPLIER_FAST               60
#define CLOCK_MULTIPLIER_FASTER             1800
#define CLOCK_MULTIPLIER_FASTEST            3600

typedef enum {
    SUNDAY = 1,
    MONDAY = 2,
    TUESDAY = 4,
    WEDNESDAY = 8,
    THURSDAY = 16,
    FRIDAY = 32,
    SATURDAY = 64
} ClockServiceRepeatDay;
