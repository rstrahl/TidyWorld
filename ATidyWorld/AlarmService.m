//
//  ClockService.m
//  A Tidy World
//
//  Created by Rudi Strahl on 12-02-14.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import "AlarmService.h"
#import "Constants.h"
#import "SettingsConstants.h"
#import "AppDelegate.h"
#import "Alarm.h"
#import "TMTimeUtils.h"
#import "ClockConstants.h"
#import <AVFoundation/AVFoundation.h>

static AlarmService *sharedClockService = nil;

// Begin Private Interface
@interface AlarmService()
/** Resets the end of day countdown and updates the current weekday bitflag used by alarm repeats 
    @param time the time from which the new day is derived */
- (void)setupNewDayWithTimeSinceReferenceDate:(NSTimeInterval)time;
/** Iterates through all enabled alarms and queues all alarms that trigger in the current day 
    @param time the time that alarms will be compared to for determining whether or not they are active */
- (void)updateActiveAlarmQueueForTimeSinceReferenceDate:(NSTimeInterval)time;
/** Checks the next alarm in the queue and triggers it if its due 
    @param time the time that will be compared to the next alarm to determine if it has been triggered */
- (void)checkAlarmTriggeredForTimeSinceReferenceDate:(NSTimeInterval)time;
/** Checks the next alarm in the snoozed queue and triggers it if its due 
    @param time the time that will be compared to the snoozed alarm to determine if it has been triggered */
- (void)checkSnoozedAlarmTriggeredForTimeSinceReferenceDate:(NSTimeInterval)time;
/** Adds an alarm to the snooze queue 
    @param alarm the alarm to add to the snooze queue */
- (void)addAlarmToSnoozeList:(Alarm *)alarm;
/** Removes an alarm from the snooze queue 
    @param alarm the alarm to remove from the snooze queue */
- (void)removeAlarmFromSnoozeList:(Alarm *)alarm;
/** Presents the alertview for an alarm 
    @param alarm the alarm that will trigger the UIAlertView */
- (void)presentAlarmAlertViewForAlarm:(Alarm *)alarm;
@end
// End Private Interface

@implementation AlarmService

@synthesize todaysAlarms = mActiveAlarmQueue,
            todaysSnoozedAlarms = mTodaysSnoozedAlarms,
            fetchedResultsController = mFetchedResultsController,
            context = mContext,
            delegate = mDelegate,
            activeAlarm = mActiveAlarm;

#pragma mark Object Lifetime
- (id)init
{
    self = [super init];
    if (self)
    {
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        self.context = [appDelegate managedObjectContext];
        mLastTimeUpdate = [NSDate timeIntervalSinceReferenceDate];

        NSError *error;
        if (![[self mFetchedResultsController] performFetch:&error])
        {
            DLog(@"ERROR loading alarm objects %@, %@", error, [error userInfo]);
        }
        DLog(@"Alarms Loaded: %d", [[self.fetchedResultsController fetchedObjects] count]);
        if ([[NSTimeZone localTimeZone] isDaylightSavingTime])
        {
            DLog(@"Local timezone is DST ENABLED");
        }
        [self updateWithTime:[NSDate timeIntervalSinceReferenceDate]];
        [self updateActiveAlarmQueueForTimeSinceReferenceDate:mLastTimeUpdate];
    }
    return self;
}

+ (id)sharedInstance {
    static dispatch_once_t safer;
    dispatch_once(&safer, ^{
        sharedClockService = [[AlarmService alloc] init];
        // private initialization goes here.
    });
    return sharedClockService;
}

#pragma mark - Time Update
- (void)updateWithTime:(NSTimeInterval)timeInterval
{
    DLog(@"Update at %@", [TMTimeUtils timeStringForTimeOfDay:timeInterval]);
    mSecondsUntilDayEnds -= timeInterval - mLastTimeUpdate;
    mLastTimeUpdate = timeInterval;
    // 1. Check for end of day
    if (mSecondsUntilDayEnds <= 0)
    {
        [self setupNewDayWithTimeSinceReferenceDate:mLastTimeUpdate];
        [self updateActiveAlarmQueueForTimeSinceReferenceDate:mLastTimeUpdate];
    }
    // 2. Check for any triggered alarms
    [self checkAlarmTriggeredForTimeSinceReferenceDate:mLastTimeUpdate];
    // 3. Check for any snoozed alarms to trigger
    [self checkSnoozedAlarmTriggeredForTimeSinceReferenceDate:mLastTimeUpdate];
}

#pragma mark - Private Methods
- (void)setupNewDayWithTimeSinceReferenceDate:(NSTimeInterval)time
{
    NSDate *today = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:today];
    mCurrentWeekday = [components weekday]-1;
    mSecondsUntilDayEnds = [TMTimeUtils timeInDayForTimeIntervalSinceReferenceDate:([today timeIntervalSinceReferenceDate] + [[NSTimeZone localTimeZone] secondsFromGMT])];
}

- (void)updateActiveAlarmQueueForTimeSinceReferenceDate:(NSTimeInterval)time
{
    NSTimeInterval timeInDayGMT = [TMTimeUtils timeInDayForTimeIntervalSinceReferenceDate:time];
    NSTimeInterval timezoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
    DLog(@"Scheduled Alarms Before Check: %d", [mActiveAlarmQueue count]);
    if (mActiveAlarmQueue == nil)
    {
        mActiveAlarmQueue = [[NSMutableArray alloc] initWithCapacity:0];
    }
    else
    {
        [mActiveAlarmQueue removeAllObjects];
    }
    
    // Get all alarms that are "enabled"
    for (Alarm *alarm in [self.fetchedResultsController fetchedObjects])
    {
        DLog(@"Alarm check - (Alarm Local: %@) (Current Time Local: %@) (Alarm GMT: %@) (Current Time GMT: %@)",
             [TMTimeUtils timeStringForTimeOfDay:alarm.time.doubleValue],
             [TMTimeUtils timeStringForTimeOfDay:(time + timezoneOffset)],
             [TMTimeUtils timeStringForTimeOfDay:(alarm.time.doubleValue - timezoneOffset)],
             [TMTimeUtils timeStringForTimeOfDay:time]);
        // Is alarm time later than now
        if ((alarm.time.doubleValue - timezoneOffset) > timeInDayGMT)
        {
            // Is alarm scheduled for today or has a repeat of today
            if (([alarm.repeat intValue] == 0) ||
                ([alarm.repeat intValue] & (1 << mCurrentWeekday)))
            {
                // add the alarm into the active alarm queue
                [mActiveAlarmQueue addObject:alarm];
            }
        }
    }
    DLog(@"Scheduled Alarms After Check: %d", [mActiveAlarmQueue count]);
}

- (void)checkAlarmTriggeredForTimeSinceReferenceDate:(NSTimeInterval)time
{
    if ([mActiveAlarmQueue count] > 0)
    {
        // Grab the alarm at the "top" of the queue (the one that comes next chronologically)
        Alarm *nextAlarm = [mActiveAlarmQueue objectAtIndex:0];
        NSTimeInterval timezoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
        
        // Alarm time is a fixed seconds-in-day point
        NSTimeInterval nextAlarmTimeAbsolute = nextAlarm.time.doubleValue;
        // Convert current time (GMT) to fixed seconds-in-day point based on local time zone
        NSTimeInterval currentTimeAbsolute = ([TMTimeUtils timeInDayForTimeIntervalSinceReferenceDate:time] + timezoneOffset);
        
        DLog(@"TRIGGER CHECK: (Alarm Local: %@) (Current Time Local: %@) (Alarm GMT: %@) (Current Time GMT: %@)",
             [TMTimeUtils timeStringForTimeOfDay:nextAlarm.time.doubleValue],
             [TMTimeUtils timeStringForTimeOfDay:(time + timezoneOffset)],
             [TMTimeUtils timeStringForTimeOfDay:(nextAlarm.time.doubleValue - timezoneOffset)],
             [TMTimeUtils timeStringForTimeOfDay:time]);
        
        // Trigger next alarm when the current time passes the alarm time
        if (nextAlarmTimeAbsolute <= currentTimeAbsolute)
        {
            // Disable alarm if its not set to repeat
            if (![nextAlarm.repeat intValue])
            {
                nextAlarm.enabled = NO;
            }
            // Remove the alarm from the queue
            [mActiveAlarmQueue removeObject:nextAlarm];
            self.activeAlarm = nextAlarm;
            [self presentAlarmAlertViewForAlarm:self.activeAlarm];
            [self.delegate alarmServiceDidTriggerAlarm:self.activeAlarm];
        }
    }
}

- (void)checkSnoozedAlarmTriggeredForTimeSinceReferenceDate:(NSTimeInterval)time
{
    if ((self.activeAlarm != nil) && (mSnoozeCount > 0))
    {
        NSTimeInterval snoozeTimer = [self.activeAlarm.time_snooze doubleValue];
        // Check if the snooze interval has passed
        if ((snoozeTimer > 0) &&
            (snoozeTimer <= time))
        {
            self.activeAlarm.time_snooze = nil;
            [self presentAlarmAlertViewForAlarm:self.activeAlarm];
            [self.delegate alarmServiceDidTriggerAlarm:self.activeAlarm];
        }
    }
}

#pragma mark - Property Overrides
- (NSFetchedResultsController *)mFetchedResultsController {
    
    if (mFetchedResultsController != nil) {
        return mFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Alarm" 
                                   inManagedObjectContext:mContext];
    [fetchRequest setEntity:entity];
    NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"enabled == YES"];
    [fetchRequest setPredicate:enabledPredicate];

    NSSortDescriptor *alarmSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:alarmSortDescriptor]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *resultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                        managedObjectContext:mContext 
                                          sectionNameKeyPath:nil 
                                                   cacheName:nil];
    self.fetchedResultsController = resultsController;
    mFetchedResultsController.delegate = self;
    
    
    return mFetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    DLog(@"Enabled Alarms in results controller: %d", [[controller fetchedObjects] count]);
    [self updateActiveAlarmQueueForTimeSinceReferenceDate:mLastTimeUpdate];
}

#pragma mark - Alarm AlertView
- (void)presentAlarmAlertViewForAlarm:(Alarm *)alarm
{
    if (alarm.snooze.boolValue)
    {
        UIAlertView *alarmAlert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"ALERT_VIEW_ALARM_TRIGGERED_TITLE", @"Alarm Alert View Title")
                                   message:alarm.title
                                   delegate:self
                                   cancelButtonTitle:NSLocalizedString(@"ALERT_VIEW_ALARM_TRIGGERED_BUTTON_OFF", @"Button Text - Turn off Alarm")
                                   otherButtonTitles:NSLocalizedString(@"ALERT_VIEW_ALARM_TRIGGERED_BUTTON_SNOOZE", @"Button Text - Snooze"), nil];
        [alarmAlert show];
    }
    else
    {
        UIAlertView *alarmAlert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"ALERT_VIEW_ALARM_TRIGGERED_TITLE", @"Alarm Alert View Title")
                                   message:alarm.title
                                   delegate:self
                                   cancelButtonTitle:NSLocalizedString(@"ALERT_VIEW_ALARM_TRIGGERED_BUTTON_OFF", @"Button Text - Turn off Alarm")
                                   otherButtonTitles:nil];
        [alarmAlert show];
    }
    
}

#pragma mark - Snooze Methods
- (void)addAlarmToSnoozeList:(Alarm *)alarm
{
    [mTodaysSnoozedAlarms addObject:alarm];
    DLog(@"ClockService: snooze alarm count: %d", [mTodaysSnoozedAlarms count]);
}

- (void)removeAlarmFromSnoozeList:(Alarm *)alarm
{
    [mTodaysSnoozedAlarms removeObject:alarm];
    DLog(@"ClockService: snooze alarm count: %d", [mTodaysSnoozedAlarms count]);
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL expireAlarm = NO;
    switch (buttonIndex) {
        case 0: // DISMISS
        {
            mSnoozeCount = 0;
            self.activeAlarm.time_snooze = nil;
            expireAlarm = YES;
            break;
        }
        case 1: // SNOOZE
        {
            if (self.activeAlarm.time_snooze.doubleValue == 0)
            {
                self.activeAlarm.time_snooze = [NSNumber numberWithDouble:mLastTimeUpdate];
            }
            mSnoozeCount++;
            self.activeAlarm.time_snooze = [NSNumber numberWithDouble:((kSnoozeIntervalInMinutes * 60) + self.activeAlarm.time_snooze.doubleValue)];
            break;
        }
        default:
            break;
    }
    [self.delegate alarmServiceDidDismissAlarm:self.activeAlarm];
    if (expireAlarm)
    {
        self.activeAlarm = nil;
    }
}

#pragma mark - Alarm Accessors
- (Alarm *)getNextAlarm
{
    if ([self.todaysAlarms count] > 0)
        return (Alarm *)[mActiveAlarmQueue objectAtIndex:0];
    else
        return nil;
}

@end
