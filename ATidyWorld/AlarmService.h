//
//  ClockService.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-02-14.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Alarm;

@protocol AlarmServiceDelegate <NSObject>
/** Signals the delegate that an alarm was triggered */
- (void)alarmServiceDidTriggerAlarm:(Alarm *)alarm;
/** Signals the delegate that an alarm was dismissed after being triggered */
- (void)alarmServiceDidDismissAlarm:(Alarm *)alarm;
@end

@interface AlarmService : NSObject <NSFetchedResultsControllerDelegate>
{
    NSTimeInterval                  mSecondsUntilDayEnds;
    NSTimeInterval                  mLastTimeUpdate;
    NSMutableArray                  *mTodaysAlarms;
    NSMutableArray                  *mTodaysSnoozedAlarms;
    Alarm                           *mActiveAlarm;
    int                             mSnoozeCount;
    int                             mCurrentWeekday;
    NSFetchedResultsController      *mFetchedResultsController;
    NSManagedObjectContext          *mContext;
    NSUserDefaults                  *mUserDefaults;
    id<AlarmServiceDelegate>        __unsafe_unretained mDelegate;

}

@property (nonatomic, strong) NSArray                               *todaysAlarms;
@property (nonatomic, strong) NSArray                               *todaysSnoozedAlarms;
@property (nonatomic, strong) Alarm                                 *activeAlarm;
@property (nonatomic, strong) NSFetchedResultsController            *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext                *context;
@property (nonatomic, unsafe_unretained) id<AlarmServiceDelegate>   delegate;

+ (id)sharedInstance;

/** Runs a single update cycle for the alarm service based on the time interval passed. */
- (void)updateWithTime:(NSTimeInterval)timeInterval;

@end



