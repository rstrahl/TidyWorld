//
//  AlarmListViewController.m
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-14.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import "AlarmListViewController.h"
#import "AlarmCellView.h"
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "SettingsConstants.h"
#import "ClockConstants.h"
#import "Alarm.h"
#import "AppDelegate.h"
#import "AlarmService.h"

@interface AlarmListViewController()
/** Helper method used to configure the layout of a UITableViewCell based on its contents */
- (void)configureEditAlarmCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
/** Checks alarm audio is valid */
- (void)checkAlarmForMissingMedia;
/** Presents a UIAlertView indicating an alarm has invalid audio assigned to it */
- (void)presentAlarmMediaNotFoundAlertViewForAlarm;
/** Adds a new alarm into core data and presents a view controller for editing the new alarm */
- (void)addAlarm;
/** Presents a new view controller for editing the given alarm */
- (void)editAlarm:(Alarm *)alarm;

// Analytics Logging Methods
- (void)googleLogAlarmAdd;
- (void)googleLogAlarmEdit;
- (void)googleLogAlarmEnabled;
@end

@implementation AlarmListViewController

@synthesize tableView = mTableView,
            alarmCell = mAlarmCell,
            addButton,
            editButton,
            doneButton,
            context = mContext,
            fetchedResultsController = mFetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"VIEW_TITLE_ALARMS", nil);
        mDateFormatter = [[NSDateFormatter alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        mUse24HourClock = [defaults boolForKey:SETTINGS_KEY_USE_24_HOUR_CLOCK];
        if (!mUse24HourClock)
        {
            [mDateFormatter setDateFormat:@"K:mm:a"];
        } 
        else
        {
            [mDateFormatter setDateFormat:@"HH:mm:a"];
        }
        AppController *delegate = (AppController *)[[UIApplication sharedApplication] delegate];
        self.context = [delegate managedObjectContext];
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
    self.navigationItem.rightBarButtonItem = self.doneButton;
    self.navigationItem.leftBarButtonItem = self.editButton;
    
    NSError *error;
	if (![[self mFetchedResultsController] performFetch:&error]) {
		DLog(@"ERROR loading core data objects %@, %@", error, [error localizedDescription]);
        if (ANALYTICS_GOOGLE_ON)
        {
            [[[GAI sharedInstance] defaultTracker] trackException:NO withNSError:error];
        }
	}
    self.contentSizeForViewInPopover = CGSizeMake(320,436);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.fetchedResultsController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // If there are no alarms, present an "add alarm" view rather than a blank list of alarms
    DLog(@"fetched alarms: %d", [self.fetchedResultsController.fetchedObjects count]);
    if ([self.fetchedResultsController.fetchedObjects count] == 0)
    {
        [self addButtonPressed:self];
    }
    if (ANALYTICS_GOOGLE_ON)
        [[GAI sharedInstance].defaultTracker trackView:@"Alarm List"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    return [mFetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[mFetchedResultsController.sections objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlarmCell";
    AlarmCellView *cell;
    cell = (AlarmCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"AlarmCellView" owner:self options:nil];
        cell = mAlarmCell;
        self.alarmCell = nil;
    }
    [self configureEditAlarmCell:cell atIndexPath:indexPath];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        DLog(@"Deleting alarm from core data");
        [mContext deleteObject:[mFetchedResultsController.fetchedObjects objectAtIndex:indexPath.row]];
                
        // Save the context.
        NSError *error;
        if (![mContext save:&error]) {
            DLog(@"Unresolved error %@, %@", error, [error localizedDescription]);
            if (ANALYTICS_GOOGLE_ON)
            {
                [[[GAI sharedInstance] defaultTracker] trackException:NO withNSError:error];
            }
        }
    }   
    [self.tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self editAlarm:[mFetchedResultsController objectAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect buttonFrame = button.frame;
    buttonFrame.origin.x = 10;
    buttonFrame.origin.y = 10;
    buttonFrame.size.width = 300;
    buttonFrame.size.height = 40;
    button.frame = buttonFrame;
    [button setTitle:NSLocalizedString(@"BUTTON_TITLE_NEW_ALARM", @"Add New Alarm") forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] 
                             withRowAnimation:UITableViewRowAnimationLeft];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                             withRowAnimation:UITableViewRowAnimationLeft];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureEditAlarmCell:[tableView cellForRowAtIndexPath:indexPath] 
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] 
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    NSError *error = nil;
    if (![mContext save:&error]) { 
        DLog(@"ERROR saving alarm data");
        if (ANALYTICS_GOOGLE_ON)
        {
            [[[GAI sharedInstance] defaultTracker] trackException:NO withNSError:error];
        }
    }
    else
    {
        DLog(@"SUCCESS saving alarm data");
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] 
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] 
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - Property Overrides
- (NSFetchedResultsController *)mFetchedResultsController {
    
    if (mFetchedResultsController != nil) {
        return mFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Alarm" inManagedObjectContext:mContext];
    [fetchRequest setEntity:entity];
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

    
    [self checkAlarmForMissingMedia];
    
    return mFetchedResultsController;
}

#pragma mark - UITableView Custom Cells
- (void)configureEditAlarmCell:(AlarmCellView *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Alarm *alarm = [mFetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    NSString *timeString = [mDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:alarm.time.doubleValue]];
    NSArray *timeComponents = [timeString componentsSeparatedByString:@":"];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@:%@", [timeComponents objectAtIndex:0], [timeComponents objectAtIndex:1]];
    cell.ampmLabel.text = [NSString stringWithFormat:@"%@", [timeComponents objectAtIndex:2]];
    [cell.ampmLabel setHidden:mUse24HourClock];
    
    // FREQUENCY
    [cell.frequencyLabel setText:[AlarmListViewController buildFrequencyStringForAlarm:alarm]];
    
    // TITLE
    [cell.titleLabel setText:alarm.title];
    
    // ENABLED
    DLog(@"Alarm.enabled: %d", [alarm.enabled boolValue]);
    [cell.enabledSwitch addTarget:self
                           action:@selector(activeSwitchWasToggled:)
                 forControlEvents:UIControlEventTouchUpInside];
    if ([alarm.enabled boolValue])
    {
        [cell.enabledSwitch setOn:YES];
    }
    else
    {
        [cell.enabledSwitch setOn:NO];
    }
        
    // PROBLEM ICON
    if ([alarm.hasProblem boolValue] == YES)
    {
        cell.problemIcon.hidden = NO;
    }
    else
    {
        cell.problemIcon.hidden = YES;
    }
}

#pragma mark - IBActions
- (IBAction)addButtonPressed:(id)sender
{
    [self addAlarm];
}

- (IBAction)editButtonPressed:(id)sender
{
    [self.tableView setEditing:YES animated:YES];
    
    // Change edit button to Done
    UIBarButtonItem *doneEditingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                target:self 
                                                                action:@selector(doneEditingButtonPressed:)];
    self.navigationItem.leftBarButtonItem = doneEditingButton;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (IBAction)doneButtonPressed:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if ([self.delegate respondsToSelector:@selector(dismissPopoverAnimated:)])
        {
            [self.delegate dismissPopoverAnimated:YES];
        }
        else
        {
            DLog(@"ERROR: DISMISSING POPOVER SHOULDN'T HAVE FAILED...");
        }
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)doneEditingButtonPressed:(id)sender
{
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItem = self.editButton;
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (IBAction)activeSwitchWasToggled:(id)sender
{
    UISwitch *enabledSwitch = (UISwitch *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Alarm *alarm = [mFetchedResultsController objectAtIndexPath:indexPath];
    [alarm setEnabled:[NSNumber numberWithBool:[enabledSwitch isOn]]];
    if ([alarm.enabled boolValue])
    {
        [self googleLogAlarmEnabled];
    }
}

#pragma mark - EditAlarmViewDelegate Methods
- (void)didReturnFromEditingAlarm:(Alarm *)alarm
{
    [self.tableView reloadData];
    [self googleLogAlarmEnabled];
}

- (void)didCancelEditingAlarm
{
    [self.tableView reloadData];
}

#pragma mark - Alarm Management
- (void)addAlarm
{
    EditAlarmViewController *editAlarmViewController = [[EditAlarmViewController alloc] initWithContext:self.context];
    editAlarmViewController.delegate = self;
    [self.navigationController pushViewController:editAlarmViewController animated:YES];
    [self googleLogAlarmAdd];
}

- (void)editAlarm:(Alarm *)alarm
{
    EditAlarmViewController *editAlarmViewController = [[EditAlarmViewController alloc] initWithContext:self.context forAlarm:alarm];
    editAlarmViewController.delegate = self;
    [self.navigationController pushViewController:editAlarmViewController animated:YES];
    [self googleLogAlarmEdit];
}

- (void)checkAlarmForMissingMedia
{
    // Check each alarm in the list, if any are missing media then present an alert view notifying the
    // user they need to update their alarms before they can be used.
    BOOL mediaIsMissing = NO;
    for (Alarm *alarm in [mFetchedResultsController fetchedObjects])
    {
        NSURL *url = [NSURL URLWithString:alarm.sound_id];
        AVURLAsset *anAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        if (anAsset == nil)
        {
            DLog(@"Alarm media was not found!");
            mediaIsMissing = YES;
            alarm.hasProblem = [NSNumber numberWithBool:YES];
        }
    }
    if (mediaIsMissing)
    {
        [self presentAlarmMediaNotFoundAlertViewForAlarm];
    }
}

- (void)presentAlarmMediaNotFoundAlertViewForAlarm
{
    UIAlertView *alarmAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"ALERT_TITLE_ALARM_MEDIA_NOT_FOUND", @"Alarm Media Missing")
                               message:NSLocalizedString(@"ALERT_TEXT_ALARM_MEDIA_NOT_FOUND", @"Alarm Media is missing text")
                               delegate:nil
                               cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                               otherButtonTitles:nil];
    [alarmAlert show];
}

#pragma mark - String Format Methods
+ (NSString *)buildFrequencyStringForAlarm:(Alarm *)alarm
{
    //    CFLocaleRef locale = CFLocaleCopyCurrent();
    //    CFDateFormatterRef formatter = CFDateFormatterCreate (NULL, locale, kCFDateFormatterMediumStyle, kCFDateFormatterMediumStyle);
    //    CFArrayRef weekdaySymbols = CFDateFormatterCopyProperty (formatter, kCFDateFormatterShortWeekdaySymbols);
    
    NSMutableString *frequencyString = [NSMutableString stringWithCapacity:0];
    NSUInteger repeatBits = [alarm.repeat intValue];
    // TODO: Localize these to use date formatter values!
    if (repeatBits == (SUNDAY + MONDAY + TUESDAY + WEDNESDAY + THURSDAY + FRIDAY + SATURDAY))
    {
        [frequencyString appendString:NSLocalizedString(@"EVERYDAY", @"Every day")];
    }
    
    else if (repeatBits == (MONDAY + TUESDAY + WEDNESDAY + THURSDAY+ FRIDAY))
    {
        [frequencyString appendString:NSLocalizedString(@"WEEKDAYS", @"Weekdays")];
    }
    else if (repeatBits == (SATURDAY + SUNDAY))
    {
        [frequencyString appendString:NSLocalizedString(@"WEEKENDS", @"Weekends")];
    }
    else
    {
        // TODO: Localize with contents of weekdayArray
        if (repeatBits & SUNDAY)
        {
            [frequencyString appendString:@"Sun "];
        }
        if (repeatBits & MONDAY)
        {
            [frequencyString appendString:@"Mon "];
        }
        if (repeatBits & TUESDAY)
        {
            [frequencyString appendString:@"Tue "];
        }
        if (repeatBits & WEDNESDAY)
        {
            [frequencyString appendString:@"Wed "];
        }
        if (repeatBits & THURSDAY)
        {
            [frequencyString appendString:@"Thu "];
        }
        if (repeatBits & FRIDAY)
        {
            [frequencyString appendString:@"Fri "];
        }
        if (repeatBits & SATURDAY)
        {
            [frequencyString appendString:@"Sat "];
        }
    }
    return frequencyString;
}


#pragma mark - Analytics Logging Methods
- (void)googleLogAlarmAdd
{
    if (ANALYTICS_GOOGLE_ON)
    {
        [[GAI sharedInstance].defaultTracker trackEventWithCategory:@"Alarms"
                                                         withAction:@"AlarmAdds"
                                                          withLabel:@"Alarm Adds"
                                                          withValue:[NSNumber numberWithInt:1]];
    }
}

- (void)googleLogAlarmEdit
{
    if (ANALYTICS_GOOGLE_ON)
    {
        [[GAI sharedInstance].defaultTracker trackEventWithCategory:@"Alarms"
                                                         withAction:@"AlarmEdits"
                                                          withLabel:@"Alarm Edits"
                                                          withValue:[NSNumber numberWithInt:1]];
    }
}

- (void)googleLogAlarmEnabled
{
    if (ANALYTICS_GOOGLE_ON)
    {
        [[GAI sharedInstance].defaultTracker trackEventWithCategory:@"Alarms"
                                                         withAction:@"AlarmEnables"
                                                          withLabel:@"Alarm Enables"
                                                          withValue:[NSNumber numberWithInt:1]];
    }
}

@end
