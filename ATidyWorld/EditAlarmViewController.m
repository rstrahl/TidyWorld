//
//  EditAlarmViewController.m
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-15.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import "EditAlarmViewController.h"
#import "AlarmListViewController.h"
#import "EditAlarmTitleViewController.h"
#import "EditAlarmRepeatViewController.h"
#import "EditAlarmSoundViewController.h"
#import "AppDelegate.h"
#import "ClockConstants.h"
#import "SettingsConstants.h"
#import "Constants.h"
#import "TMTimeUtils.h"

@implementation EditAlarmViewController

@synthesize tableView = mTableView,
            timePicker = mTimePicker,
            saveButton = mSaveButton,
            cancelButton = mCancelButton,
            alarm = mAlarm,
            delegate = mDelegate,
            context = mContext;

- (id)initWithContext:(NSManagedObjectContext *)context;
{
    if (self = [super init])
    {
        self.context = context;
        self.title = NSLocalizedString(@"VIEW_TITLE_NEW_ALARM", @"Add Alarm");
        mIsSaved = NO;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithContext:(NSManagedObjectContext *)context forAlarm:(Alarm *)alarm
{
    if (self = [super init])
    {
        self.context = context;
        self.alarm = alarm;
        self.title = NSLocalizedString(@"VIEW_TITLE_EDIT_ALARM", @"Edit Alarm");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    mSaveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                target:self 
                                                                action:@selector(saveButtonPressed:)];
    mCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                  target:self 
                                                                  action:@selector(cancelButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:mSaveButton];
    [self.navigationItem setLeftBarButtonItem:mCancelButton];
    
    if (self.alarm == nil)
    {
        self.alarm = (Alarm *)[NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:self.context];
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:ALARM_DEFAULT_SOUND_FILE];
        NSURL *assetUrl = [NSURL fileURLWithPath:path];
        self.alarm.sound_id = [NSString stringWithFormat:@"%@", assetUrl];
        mIsNewAlarm = YES;
        self.alarm.title = NSLocalizedString(@"DEFAULT_ALARM_TITLE", @"Alarm");
        
        NSURL *assetURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                                  [[NSBundle mainBundle] resourcePath],
                                                  ALARM_DEFAULT_SOUND_FILE]];
        self.alarm.sound_id = [NSString stringWithFormat:@"%@", assetURL];
        self.alarm.sound_name = ALARM_DEFAULT_SOUND_NAME;
        self.alarm.enabled = [NSNumber numberWithBool:YES];
    }
    
    // Picker time is today in seconds + the alarm time since midnight of its original day
    [self.timePicker setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    if ([self.alarm.time doubleValue])
    {
        [self.timePicker setDate:[TMTimeUtils dateForTimeInSecondsToday:self.alarm.time.doubleValue]];
    }
    else
    {
        // New time:  nowInGMT + localTimeZone + DST adjustment
        NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate] + [[NSTimeZone localTimeZone] secondsFromGMT];
        [self.timePicker setDate:[NSDate dateWithTimeIntervalSinceReferenceDate:time]];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL use24HourClock = [defaults boolForKey:SETTINGS_KEY_USE_24_HOUR_CLOCK];
    if (use24HourClock)
    {
        [self.timePicker setDatePickerMode:UIDatePickerModeTime];
    }
    self.contentSizeForViewInPopover = CGSizeMake(320,436);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableView = nil;
    self.timePicker = nil;
    self.saveButton = nil;
    self.cancelButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (ANALYTICS)
        [[GAI sharedInstance].defaultTracker trackView:@"Edit Alarm"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        switch (indexPath.row)
        {
                // Repeat Cell
            case 0:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.textLabel.text = NSLocalizedString(@"CELL_TITLE_REPEAT", @"Repeat Alarm");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
                // Sound Cell
            case 1:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.textLabel.text = NSLocalizedString(@"CELL_TITLE_ALARM_SOUND", @"Alarm Sound");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
                // Snooze Cell
            case 2:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.textLabel.text = NSLocalizedString(@"CELL_TITLE_SNOOZE", @"Snooze");
                mSnoozeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(224, 9, 0, 0)];
                [cell addSubview:mSnoozeSwitch];
                [mSnoozeSwitch addTarget:self action:@selector(snoozeSwitchToggled:) forControlEvents:UIControlEventValueChanged];
                break;
            }
                // Label Cell
            case 3:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.textLabel.text = NSLocalizedString(@"CELL_TITLE_ALARM_TITLE", @"Title");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            default:
                break;
        }
    }
    
    // Cell Contents
    switch (indexPath.row)
    {
            // Repeat Cell
        case 0:
        {
            cell.detailTextLabel.text = [AlarmListViewController buildFrequencyStringForAlarm:mAlarm];
            break;
        }
            // Sound Cell
        case 1:
        {
            cell.detailTextLabel.text = mAlarm.sound_name;
            break;
        }
            // Snooze Cell
        case 2:
        {
            [mSnoozeSwitch setOn:[mAlarm.snooze boolValue]];
            break;
        }
            // Label Cell
        case 3:
        {
            if ([mAlarm.title length] > 0)
            {
                cell.detailTextLabel.text = mAlarm.title;
            }
            else
            {
                cell.detailTextLabel.text = NSLocalizedString(@"DEFAULT_ALARM_TITLE", @"Alarm");
            }
            break;
        }
        default:
            break;
    }

    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0: // Repeat Cell
        {    
            EditAlarmRepeatViewController *editAlarmRepeatViewController = 
            [[EditAlarmRepeatViewController alloc] init];
            editAlarmRepeatViewController.delegate = self;
            editAlarmRepeatViewController.repeatBits = [mAlarm.repeat intValue];
            [self.navigationController pushViewController:editAlarmRepeatViewController animated:YES];
            break;
        }   
        case 1: // Sound Cell
        {
            EditAlarmSoundViewController *editAlarmSoundViewController = 
                [[EditAlarmSoundViewController alloc] init];
            editAlarmSoundViewController.delegate = self;
            editAlarmSoundViewController.selectedMediaID = mAlarm.sound_id;
            editAlarmSoundViewController.selectedMediaName = mAlarm.sound_name;
            [self.navigationController pushViewController:editAlarmSoundViewController animated:YES];
            break;
        }
        case 2: // Snooze Cell
        {
            break;
        }
        case 3: // Label Cell
        {
            EditAlarmTitleViewController *editAlarmTitleViewController = 
                [[EditAlarmTitleViewController alloc] init];
            editAlarmTitleViewController.delegate = self;
            editAlarmTitleViewController.alarmTitle = mAlarm.title;
            [self.navigationController pushViewController:editAlarmTitleViewController animated:YES];
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 70;
//}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2)
        return nil;
    return indexPath;
}

#pragma mark - IBActions
- (IBAction)saveButtonPressed:(id)sender
{
    // We save the time of the alarm as the time during the day - datepicker always includes DATE
//    NSTimeInterval time = [self.timePicker.date timeIntervalSinceReferenceDate] + [[NSTimeZone localTimeZone] secondsFromGMT];
    NSTimeInterval time = [self.timePicker.date timeIntervalSinceReferenceDate];
    NSTimeInterval alarmTime = [TMTimeUtils timeInDayForTimeIntervalSinceReferenceDate:(time - ((int)time % 60))];
//    if (mIsNewAlarm)
//    {
//        if ([[NSTimeZone localTimeZone] isDaylightSavingTime])
//        {
//            alarmTime += [[NSTimeZone localTimeZone] daylightSavingTimeOffset];
//        }
//    }
    mAlarm.time = [NSNumber numberWithDouble:alarmTime];
    mAlarm.hasProblem = [NSNumber numberWithBool:NO];
    // Save object in context
    NSError *error;
    if (![mContext save:&error]) {
        DLog(@"ERROR saving alarm to context: %@", [error localizedDescription]);
    }
    else
    {
        mIsSaved = YES;
        DLog(@"Saved alarm wth time: %@ ", [TMTimeUtils timeStringForTimeOfDay:mAlarm.time.doubleValue]);
    }
    
    [self.delegate didReturnFromEditingAlarm:mAlarm];
    [self.navigationController popViewControllerAnimated:YES];
}

// TODO: CODE REVIEW: No longer used, viewWillDisappear now accounts for this as we're using a back button
- (IBAction)cancelButtonPressed:(id)sender
{
    [self.context rollback];
    if (mIsNewAlarm)
    {
        [self.context deleteObject:mAlarm];
    }
    [mDelegate didCancelEditingAlarm];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)snoozeSwitchToggled:(id)sender
{
    UISwitch *snoozeSwitch = (UISwitch *)sender;
    if (snoozeSwitch.isOn)
    {
        mAlarm.snooze = [NSNumber numberWithBool:YES];
    }
    else {
        mAlarm.snooze = [NSNumber numberWithBool:NO];
    }
}

#pragma mark - EditAlarmElementViewDelegate Methods
- (void)didReturnFromEditingAlarmElement:(NSString *)key withValue:(NSObject *)value
{
    if ([key isEqualToString:@"title"])
    {
        mAlarm.title = (NSString *)value;
    }
    else if ([key isEqualToString:@"repeat"])
    {
        mAlarm.repeat = (NSNumber *)value;
    }
    else if ([key isEqualToString:@"sound"])
    {
        NSDictionary *soundDict = (NSDictionary *)value;
        mAlarm.sound_id = [soundDict valueForKey:@"id"];
        mAlarm.sound_name = [soundDict valueForKey:@"name"];
        NSLog(@"Alarm sound id: %@", mAlarm.sound_id);
    }
    [mTableView reloadData];
}
@end
