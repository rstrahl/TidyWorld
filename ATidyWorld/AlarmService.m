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
#import "TimeUtils.h"
#import "ClockConstants.h"
#import <AVFoundation/AVFoundation.h>

static AlarmService *sharedClockService = nil;

// Begin Private Interface
@interface AlarmService()
- (void)setupNewDay;
- (void)refreshActiveAlarmsBasedOnTime:(NSTimeInterval)time;
- (void)checkAlarmTriggeredForTime:(NSTimeInterval)time;
- (void)checkSnoozedAlarmTriggeredForTime:(NSTimeInterval)time;
- (void)addAlarmToSnoozeList:(Alarm *)alarm;
- (void)removeAlarmFromSnoozeList:(Alarm *)alarm;
- (void)presentAlarmAlertViewForAlarm:(Alarm *)alarm;
- (Alarm *)getNextAlarm;
@end
// End Private Interface

@implementation AlarmService

@synthesize todaysAlarms = mTodaysAlarms,
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
        [self refreshActiveAlarmsBasedOnTime:mLastTimeUpdate];

        NSError *error;
        if (![[self mFetchedResultsController] performFetch:&error])
        {
            DLog(@"ERROR loading alarm objects %@, %@", error, [error userInfo]);
        }
        DLog(@"Alarms Loaded: %d", [[self.fetchedResultsController fetchedObjects] count]);
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
    DLog(@"Updating alarm service...");
    mLastTimeUpdate = timeInterval;
    // 1. Check for end of day
    mSecondsUntilDayEnds--;
    if (mSecondsUntilDayEnds <= 0)
    {
        [self setupNewDay];
        [self refreshActiveAlarmsBasedOnTime:mLastTimeUpdate];
    }
    // 2. Check for any triggered alarms
    [self checkAlarmTriggeredForTime:mLastTimeUpdate];
    // 3. Check for any snoozed alarms to trigger
    [self checkSnoozedAlarmTriggeredForTime:mLastTimeUpdate];
}

#pragma mark - Private Methods
- (void)setupNewDay
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:today];
    mCurrentWeekday = [components weekday]-1;
    mSecondsUntilDayEnds = [TimeUtils timeInDayForTimeIntervalSinceReferenceDate:[today timeIntervalSinceReferenceDate]];
}

- (void)refreshActiveAlarmsBasedOnTime:(NSTimeInterval)time
{
    NSTimeInterval timeInDay = [TimeUtils timeInDayForTimeIntervalSinceReferenceDate:time];
    DLog(@"Scheduled Alarms Before Check: %d", [mTodaysAlarms count]);
    if (mTodaysAlarms == nil)
    {
        mTodaysAlarms = [[NSMutableArray alloc] initWithCapacity:0];
    }
    else
    {
        [mTodaysAlarms removeAllObjects];
    }
    
    for (Alarm *alarm in [self.fetchedResultsController fetchedObjects])
    {
        DLog(@"Alarm time: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:alarm.time.doubleValue]);
        DLog(@"Curr. time: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:timeInDay]);
        // Is alarm time within today's time range
        if (alarm.time.doubleValue >= timeInDay)
        {
            // Is alarm scheduled for today or has a repeat of today
            if (([alarm.repeat intValue] == 0) ||
                ([alarm.repeat intValue] & (1 << mCurrentWeekday)))
            {
                [mTodaysAlarms addObject:alarm];
            }
        }
    }
    DLog(@"Scheduled Alarms After Check: %d", [mTodaysAlarms count]);
}

- (void)checkAlarmTriggeredForTime:(NSTimeInterval)time
{
    if ([mTodaysAlarms count] > 0)
    {
        Alarm *nextAlarm = [mTodaysAlarms objectAtIndex:0];
        NSTimeInterval nextAlarmTime = [TimeUtils timeInDayForTimeIntervalSinceReferenceDate:nextAlarm.time.doubleValue];
        
        // Trigger next alarm when the current time passes the alarm time
        if (nextAlarmTime <= time)
        {
            // Disable alarm if its not set to repeat
            if (![nextAlarm.repeat intValue])
            {
                nextAlarm.enabled = NO;
            }
            [mTodaysAlarms removeObject:nextAlarm];
            self.activeAlarm = nextAlarm;
            [self presentAlarmAlertViewForAlarm:self.activeAlarm];
            [self.delegate alarmServiceDidTriggerAlarm:self.activeAlarm];
        }
    }
}

- (void)checkSnoozedAlarmTriggeredForTime:(NSTimeInterval)time
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
    [self refreshActiveAlarmsBasedOnTime:mLastTimeUpdate];
}

#pragma mark - Alarm AlertView
- (void)presentAlarmAlertViewForAlarm:(Alarm *)alarm
{
    UIAlertView *alarmAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"ALERT_VIEW_ALARM_TRIGGERED_TITLE", @"Alarm Alert View Title")
                               message:alarm.title
                               delegate:self
                               cancelButtonTitle:NSLocalizedString(@"ALERT_VIEW_ALARM_TRIGGERED_BUTTON_OFF", @"Button Text - Turn off Alarm")
                               otherButtonTitles:NSLocalizedString(@"ALERT_VIEW_ALARM_TRIGGERED_BUTTON_SNOOZE", @"Button Text - Snooze"), nil];
    [alarmAlert show];
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
        return (Alarm *)[mTodaysAlarms objectAtIndex:0];
    else
        return nil;
}

@end
