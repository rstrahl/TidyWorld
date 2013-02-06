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

@implementation EditAlarmViewController

@synthesize tableView = _tableView,
            timePicker = _timePicker,
            saveButton = _saveButton,
            cancelButton = _cancelButton,
            alarm = _alarm,
            delegate = _delegate,
            context = _context;

- (id)initWithContext:(NSManagedObjectContext *)context;
{
    if (self = [super init])
    {
        self.context = context;
        self.title = NSLocalizedString(@"VIEW_TITLE_NEW_ALARM", @"Add Alarm");
        _isSaved = NO;
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
    _saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                target:self 
                                                                action:@selector(saveButtonPressed:)];
    _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                  target:self 
                                                                  action:@selector(cancelButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:_saveButton];
    [self.navigationItem setLeftBarButtonItem:_cancelButton];
    
    self.alarm = (Alarm *)[NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:self.context];
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:ALARM_DEFAULT_SOUND_FILE];
    NSURL *assetUrl = [NSURL fileURLWithPath:path];
    self.alarm.sound_id = [NSString stringWithFormat:@"%@", assetUrl];
    
    if ([self.alarm.time intValue] == 0)
    {
        _isNewAlarm = YES;
        self.alarm.title = NSLocalizedString(@"DEFAULT_ALARM_TITLE", @"Alarm");
        
        NSURL *assetURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                                  [[NSBundle mainBundle] resourcePath],
                                                  ALARM_DEFAULT_SOUND_FILE]];
        self.alarm.sound_id = [NSString stringWithFormat:@"%@", assetURL];
        self.alarm.sound_name = ALARM_DEFAULT_SOUND_NAME;
    }
    
    // Picker time is today in seconds + the alarm time since midnight of its original day
    if ([self.alarm.time intValue])
    {
        NSTimeInterval alarmTimeDay = [_alarm.time doubleValue];// + dayInSeconds;
        [self.timePicker setDate:[NSDate dateWithTimeIntervalSinceReferenceDate:alarmTimeDay]];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL use24HourClock = [defaults boolForKey:SETTINGS_KEY_USE_24_HOUR_CLOCK];
    if (use24HourClock)
    {
        [self.timePicker setDatePickerMode:UIDatePickerModeTime];
    }
    [self.timePicker setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
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
    if (ANALYTICS_GOOGLE_ON)
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
                _snoozeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(224, 9, 0, 0)];
                [cell addSubview:_snoozeSwitch];
                [_snoozeSwitch addTarget:self action:@selector(snoozeSwitchToggled:) forControlEvents:UIControlEventValueChanged];
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
            cell.detailTextLabel.text = [AlarmListViewController buildFrequencyStringForAlarm:_alarm];
            break;
        }
            // Sound Cell
        case 1:
        {
            cell.detailTextLabel.text = _alarm.sound_name;
            break;
        }
            // Snooze Cell
        case 2:
        {
            [_snoozeSwitch setOn:[_alarm.snooze boolValue]];
            break;
        }
            // Label Cell
        case 3:
        {
            if ([_alarm.title length] > 0)
            {
                cell.detailTextLabel.text = _alarm.title;
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
            editAlarmRepeatViewController.repeatBits = [_alarm.repeat intValue];
            [self.navigationController pushViewController:editAlarmRepeatViewController animated:YES];
            break;
        }   
        case 1: // Sound Cell
        {
            EditAlarmSoundViewController *editAlarmSoundViewController = 
                [[EditAlarmSoundViewController alloc] init];
            editAlarmSoundViewController.delegate = self;
            editAlarmSoundViewController.selectedMediaID = _alarm.sound_id;
            editAlarmSoundViewController.selectedMediaName = _alarm.sound_name;
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
            editAlarmTitleViewController.alarmTitle = _alarm.title;
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
    NSUInteger pickerTimeInSeconds = (NSUInteger)floor([[_timePicker date] timeIntervalSinceReferenceDate]);
    NSTimeInterval alarmTimeInSecondsOfDay = (double)((pickerTimeInSeconds % (int)kOneDayInSeconds) / 60) * 60;
//    NSLog(@"saveButtonPressed: Current date and time: %@", [NSDate date]);
//    NSLog(@"saveButtonpressed: Alarm time in millis: %f", alarmTimeInSecondsOfDay);
//    NSLog(@"saveButtonPressed: Alarm date and time: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:pickerTimeInSeconds]);
    _alarm.time = [NSNumber numberWithDouble:alarmTimeInSecondsOfDay];
    _alarm.hasProblem = [NSNumber numberWithBool:NO];
    // Save object in context
    NSError *error;
    if (![_context save:&error]) {
        DLog(@"ERROR saving alarm to context: %@", [error localizedDescription]);
    }
    else
    {
        _isSaved = YES;
        DLog(@"saveButtonPressed: SUCCESS saving alarm");
    }
    
    [self.delegate didReturnFromEditingAlarm:_alarm];
    [self.navigationController popViewControllerAnimated:YES];
}

// TODO: CODE REVIEW: No longer used, viewWillDisappear now accounts for this as we're using a back button
- (IBAction)cancelButtonPressed:(id)sender
{
    [self.context rollback];
    if (_isNewAlarm)
    {
        [self.context deleteObject:_alarm];
    }
    [_delegate didCancelEditingAlarm];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)snoozeSwitchToggled:(id)sender
{
    UISwitch *snoozeSwitch = (UISwitch *)sender;
    if (snoozeSwitch.isOn)
    {
        _alarm.snooze = [NSNumber numberWithBool:YES];
    }
    else {
        _alarm.snooze = [NSNumber numberWithBool:NO];
    }
}

#pragma mark - EditAlarmElementViewDelegate Methods
- (void)didReturnFromEditingAlarmElement:(NSString *)key withValue:(NSObject *)value
{
    if ([key isEqualToString:@"title"])
    {
        _alarm.title = (NSString *)value;
    }
    else if ([key isEqualToString:@"repeat"])
    {
        _alarm.repeat = (NSNumber *)value;
    }
    else if ([key isEqualToString:@"sound"])
    {
        NSDictionary *soundDict = (NSDictionary *)value;
        _alarm.sound_id = [soundDict valueForKey:@"id"];
        _alarm.sound_name = [soundDict valueForKey:@"name"];
        NSLog(@"Alarm sound id: %@", _alarm.sound_id);
    }
    [_tableView reloadData];
}
@end
