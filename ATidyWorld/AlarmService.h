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
/** Signals the delegate that an alarm was triggered 
    @param alarm the alarm that was triggered */
- (void)alarmServiceDidTriggerAlarm:(Alarm *)alarm;
/** Signals the delegate that an alarm was dismissed after being triggered 
    @param alarm the alarm that was dismissed */
- (void)alarmServiceDidDismissAlarm:(Alarm *)alarm;
@end

/** <p>The alarm service manages the state of any {@link Alarm} object that has the Enabled flag set. When the {@link #updateWithTime} method is called, the service makes a single check to determine if its next {@link Alarm} is triggered. The service is designed to store alarms in a queue according to their timestamp in ascending value; the check performed thus only checks the alarm at index 0.</p>
    <p>When an alarm has been triggered, dismissed, or snoozed, the {@link AlarmServiceDelegate} is notified and should 
    perform any tasks for notifying the user.  A UIAlertView is presented by default.</p>
    @see Alarm
 */
@interface AlarmService : NSObject <NSFetchedResultsControllerDelegate>
{
    @private
    NSTimeInterval                  mSecondsUntilDayEnds; /**< number of seconds until end of day */
    NSTimeInterval                  mLastTimeUpdate; /**< the last time interval received by the service */
    NSMutableArray                  *mActiveAlarmQueue; /**< the queue of alarms that are eligible to be triggered in the current day */
    NSMutableArray                  *mTodaysSnoozedAlarms; /**< the queue of alarms that have been snoozed */
    Alarm                           *mActiveAlarm; /**< the currently triggered alarm, if an alarm has been triggered */
    int                             mSnoozeCount; /**< the number of times the currently triggered alarm has been snoozed */
    int                             mCurrentWeekday; /**< the current weekday (0 = sunday, 6 = saturday) */
    NSFetchedResultsController      *mFetchedResultsController; /**< the results controller containing all alarms with the enabled flag set */
    NSManagedObjectContext          *mContext; /**< the reference to the application delegate's NSManagedObjectContext */
    id<AlarmServiceDelegate>        __unsafe_unretained mDelegate; /**< the delegate intended to respond to alarm service events */
}

@property (nonatomic, strong) NSArray                               *todaysAlarms;
@property (nonatomic, strong) NSArray                               *todaysSnoozedAlarms;
@property (nonatomic, strong) Alarm                                 *activeAlarm;
@property (nonatomic, strong) NSFetchedResultsController            *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext                *context;
@property (nonatomic, unsafe_unretained) id<AlarmServiceDelegate>   delegate;

/** Returns the singleton instance of the AlarmService object 
    @return a reference to the service instance */
+ (id)sharedInstance;
/** Runs a single update cycle for the alarm service based on the time interval passed. 
    @param timeInterval a time interval since reference date */
- (void)updateWithTime:(NSTimeInterval)timeInterval;
/** Gets the next alarm from the queue 
    @return the next alarm in the active alarms queue */
- (Alarm *)getNextAlarm;
@end



