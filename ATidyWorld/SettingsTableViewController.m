//
//  OptionsTableViewController.m
//  TidyTime
//
//  Created by Rudi Strahl on 2012-08-01.
//
//

#import "SettingsTableViewController.h"
#import "SettingsConstants.h"
#import "Constants.h"

@interface SettingsTableViewController ()
/** Saves the settings into the UserDefaults if any have changed */
- (void)saveSettings;
/** Helper method for configuring the layout of cells within the table based on their contents */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation SettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        mUserDefaults = [NSUserDefaults standardUserDefaults];
        mOptionsTableSectionHeaders = [[NSArray alloc] initWithObjects:
                                      NSLocalizedString(@"OPTIONS_SECTION_HEADER_GENERAL", @"General"),
                                       NSLocalizedString(@"OPTIONS_SECTION_HEADER_DISPLAY", @"Display"),
                                       NSLocalizedString(@"OPTIONS_SECTION_HEADER_TIME", @"Time"),
//                                       NSLocalizedString(@"OPTIONS_SECTION_HEADER_ALARM", @"Alarm"),
                                       nil];
        mGeneralOptionsData = [[NSArray alloc] initWithObjects:
                               SETTINGS_KEY_USE_CELSIUS,
                               SETTINGS_KEY_USE_24_HOUR_CLOCK,
                               nil];
        mDisplayOptionsData = [[NSArray alloc] initWithObjects:
                               SETTINGS_KEY_SHOW_DATE,
                               SETTINGS_KEY_SHOW_TEMP,
                               nil];
        mTimeOptionsData = [[NSMutableArray alloc] initWithObjects:
                            SETTINGS_KEY_CLOCK_MULTIPLIER,
                            nil];
//        mAlarmOptionsData = [[NSArray alloc] initWithObjects:
//                             SETTINGS_KEY_FADE_IN_MUSIC,
//                             nil];
        mOptionsTableData = [[NSArray alloc] initWithObjects:
                             mGeneralOptionsData,
                             mDisplayOptionsData,
                             mTimeOptionsData,
                             nil];
        
        self.title = NSLocalizedString(@"VIEW_TITLE_OPTIONS", @"Options Screen Title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    mSettingsChanged = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320,460);
    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+20);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 45)];
	footer.backgroundColor = [UIColor clearColor];
	self.tableView.tableFooterView = footer;
    [self.tableView reloadData];
    if (ANALYTICS)
        [[GAI sharedInstance].defaultTracker trackView:@"Settings View"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self saveSettings];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [mOptionsTableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[mOptionsTableData objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [mOptionsTableSectionHeaders objectAtIndex:section];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UITableViewCell
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[mOptionsTableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *cellText = [NSString stringWithFormat:NSLocalizedString([[mOptionsTableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row], @"String for key matching OptionsConstant entry")];
    cell.textLabel.text = cellText;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    // The key determines the control type for the cell and the label
    // Its also the key used in the "possible values" dictionary (should be stored in OptionsConstants
    if ([key isEqualToString:SETTINGS_KEY_SHOW_DATE] ||
        [key isEqualToString:SETTINGS_KEY_SHOW_TEMP] ||
        [key isEqualToString:SETTINGS_KEY_SHOW_FROST_FRAME] ||
        [key isEqualToString:SETTINGS_KEY_SHOW_NEXT_ALARM])
    {
        DLog(@"Setting cell: %@", cell.textLabel.text);
        UISwitch *cellSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [cellSwitch setOn:[[mUserDefaults valueForKey:key] boolValue]];
        [cellSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
        [cell setAccessoryView:cellSwitch];
    }
    else if ([key isEqualToString:SETTINGS_KEY_CLOCK_MULTIPLIER])
    {
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        slider.minimumValue = 0;
        slider.maximumValue = 3;
        [cell setAccessoryView:slider];
        slider.value = [[mUserDefaults valueForKey:SETTINGS_KEY_CLOCK_MULTIPLIER] floatValue];
    }
    else if ([key isEqualToString:SETTINGS_KEY_USE_24_HOUR_CLOCK])
    {
        NSArray *segmentTitles = [NSArray arrayWithObjects:
                                  NSLocalizedString(@"12_HOUR_SYMBOL", @"12 Hours"),
                                  NSLocalizedString(@"24_HOUR_SYMBOL", @"24 Hours"),
                                  nil];
        UISegmentedControl *cellSegment = [[UISegmentedControl alloc] initWithItems:segmentTitles];
        [cellSegment setSegmentedControlStyle:UISegmentedControlStyleBar];
        [cellSegment setSelectedSegmentIndex:[[mUserDefaults valueForKey:key] intValue]];
        [cellSegment setWidth:36.0f forSegmentAtIndex:0];
        [cellSegment setWidth:36.0f forSegmentAtIndex:1];
        [cellSegment addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventValueChanged];
        [cell setAccessoryView:cellSegment];
    }
    else if ([key isEqualToString:SETTINGS_KEY_USE_CELSIUS])
    {
        NSArray *segmentTitles = [NSArray arrayWithObjects:
                                  NSLocalizedString(@"FAHRENHEIT", @"F"),
                                  NSLocalizedString(@"CELSIUS", @"C"),
                                  nil];
        UISegmentedControl *cellSegment = [[UISegmentedControl alloc] initWithItems:segmentTitles];
        [cellSegment setSegmentedControlStyle:UISegmentedControlStyleBar];
        [cellSegment setSelectedSegmentIndex:[[mUserDefaults valueForKey:key] intValue]];
        [cellSegment setWidth:36.0f forSegmentAtIndex:0];
        [cellSegment setWidth:36.0f forSegmentAtIndex:1];
        [cellSegment addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventValueChanged];
        [cell setAccessoryView:cellSegment];
    }
//    else if ([key isEqualToString:SETTINGS_KEY_IN_APP_PURCHASES])
//    {
//        cell.textLabel.text = NSLocalizedString(@"IN_APP_PURCHASES", @"In-App Purchases");
//        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
//    }
}

#pragma mark - IBActions
- (IBAction)doneButtonPressed:(id)sender
{
    [self saveSettings];
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

- (IBAction)switchToggled:(id)sender
{
    UISwitch *cellSwitch = (UISwitch *)sender;
    UITableViewCell *cell = (UITableViewCell *)cellSwitch.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *key = [[mOptionsTableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    [mUserDefaults setBool:cellSwitch.isOn forKey:key];
    DLog(@"Changed value of option: %@ to %d", key, cellSwitch.isOn);
    mSettingsChanged = YES;
}

- (IBAction)segmentSelected:(id)sender
{
    UISegmentedControl *cellSegment = (UISegmentedControl *)sender;
    UITableViewCell *cell = (UITableViewCell *)cellSegment.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *key = [[mOptionsTableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    [mUserDefaults setBool:(BOOL)cellSegment.selectedSegmentIndex forKey:key];
    DLog(@"Changed value of option: %@ to %d", key, cellSegment.selectedSegmentIndex);
    mSettingsChanged = YES;
}

- (IBAction)sliderValueChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    NSUInteger value = roundf(slider.value);
    [slider setValue:value];
    UITableViewCell *cell = (UITableViewCell *)slider.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *key = [[mOptionsTableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString([[mOptionsTableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row], @"String for key matching OptionsConstant entry"), value];
    [mUserDefaults setBool:NO forKey:SETTINGS_KEY_CLOCK_IS_TIME_LAPSE];
    if (value != TMClockTimeLapseNormal)
    {
        [mUserDefaults setBool:YES forKey:SETTINGS_KEY_CLOCK_IS_TIME_LAPSE];
    }
    [mUserDefaults setInteger:value forKey:key];
    DLog(@"Changed value of option: %@ to %d", key, value);
    mSettingsChanged = YES;
}

#pragma mark - Settings Load/Save Methods
- (void)saveSettings
{
    if (mSettingsChanged)
    {
        BOOL saveResults = [mUserDefaults synchronize];
        
        if (!saveResults)
        {
            DLog(@"ERROR saving userDefaults!");
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SETTINGS_CHANGED
                                                            object:self];
        mSettingsChanged = NO;
    }
}

@end
