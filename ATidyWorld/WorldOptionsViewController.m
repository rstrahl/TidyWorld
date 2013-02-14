//
//  WorldOptionsViewController.m
//  TidyTime
//
//  Created by Rudi Strahl on 2012-10-09.
//
//

#import "WorldOptionsViewController.h"
#import "SelectWeatherOptionViewController.h"
#import "Constants.h"
#import "SettingsConstants.h"

@interface WorldOptionsViewController ()
/** Helper method for configuring table view cell based on its contents */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
/** Adds switch to cell and configures it based on the key of the cell */
- (void)addSwitchToCell:(UITableViewCell *)cell forKey:(NSString *)key;
/** Identifies the world option to use for a cell based on the index path */
- (NSDictionary *)worldOptionForIndexPath:(NSIndexPath *)indexPath;
/** Indicates the location-based value is about to be changed after a UI interaction */
- (void)locationBasedValueChanged:(BOOL)value;
/** Indicates the rain value is about to be changed after a UI interaction */
- (void)rainValueChangedWithRowValue:(NSUInteger)value;
/** Indicates the snow value is about to be changed after a UI interaction */
- (void)snowValueChangedRowValue:(NSUInteger)value;
/** Indicates the clouds value is about to be changed after a UI interaction */
- (void)cloudsValueChangedRowValue:(NSUInteger)value;
/** Indicates the fog value is about to be changed after a UI interaction */
- (void)fogValueChanged:(BOOL)value;
/** Indicates the lightning value is about to be changed after a UI interaction */
- (void)lightningValueChanged:(BOOL)value;
/** Indicates the season value is about to be changed after a UI interaction */
- (void)seasonValueChanged:(NSInteger)value;
/** Records the change of a World Option with google analytics if it is enabled */
- (void)googleLogWorldOptionChanged:(NSString *)option;
@end

@implementation WorldOptionsViewController

@synthesize tableData = mTableData,
            delegate = mDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.title = NSLocalizedString(@"VIEW_TITLE_WORLD_OPTIONS", @"World Options Screen Title");
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    if (ANALYTICS_GOOGLE_ON)
        [[GAI sharedInstance].defaultTracker trackView:@"World Options"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self saveSettings];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setRightBarButtonItem:self.doneButton];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSString *filePath = [[NSBundle mainBundle] bundlePath];
    NSString *dataPath = [filePath stringByAppendingPathComponent:@"WorldOptions.plist"];
    
#ifdef TESTING
    UIBarButtonItem *feedbackButton = [[UIBarButtonItem alloc] initWithTitle:@"Feedback!" style:UIBarButtonItemStyleBordered target:self action:@selector(feedbackButtonPressed:)];
    self.navigationItem.leftBarButtonItem = feedbackButton;
#endif
    
    mTableData = [[NSArray alloc] initWithContentsOfFile:dataPath];
    
    mUserDefaults = [NSUserDefaults standardUserDefaults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [mTableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[mTableData objectAtIndex:section] valueForKey:@"Rows"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionDict = [mTableData objectAtIndex:section];
    return [sectionDict valueForKey:@"Header"];
}

#pragma mark - UITableViewDelegate Implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellDict = [self worldOptionForIndexPath:indexPath];
    SelectWeatherOptionViewController *detailViewController = [[SelectWeatherOptionViewController alloc] initWithNibName:@"SelectWeatherOptionViewController" bundle:nil];
    [detailViewController setTableData:[self worldOptionForIndexPath:indexPath]];
    detailViewController.weatherOptionDelegate = self;
    NSString *key = [cellDict valueForKey:@"Header"];
    detailViewController.title = key;
    detailViewController.checkedRow = [self currentValueForWeatherOptionKey:key];
    detailViewController.weatherCategory = indexPath.row;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellDict = [self worldOptionForIndexPath:indexPath];
    NSString *key = [cellDict valueForKey:@"Header"];
    cell.textLabel.text = key;

    // Handle switch-oriented World Options
    if ([key isEqualToString:@"Location Based"] ||
        [key isEqualToString:@"Fog"] ||
        [key isEqualToString:@"Lightning"] ||
        [key isEqualToString:@"Use Real-World Time"])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSwitchToCell:cell forKey:key];
    }
    // Handle multiple-choice World Options
    else
    {
        cell.detailTextLabel.text = [[cellDict valueForKey:@"Rows"] objectAtIndex:[self currentValueForWeatherOptionKey:key]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
}
- (void)addSwitchToCell:(UITableViewCell *)cell forKey:(NSString *)key
{
    UISwitch *cellSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [cellSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    [cell setAccessoryView:cellSwitch];
    [cellSwitch setOn:[self currentValueForWeatherOptionKey:key]];
    if ([key isEqualToString:@"Lightning"])
    {
        if ([mUserDefaults integerForKey:@"CURRENT_CLOUDS"] == WeatherCloudsNone)
        {
            cellSwitch.enabled = NO;
            cellSwitch.hidden = YES;
        }
    }
}

- (NSInteger)currentValueForWeatherOptionKey:(NSString *)key
{
    NSInteger returnValue = 0;
    if ([key isEqualToString:@"Clouds"])
    {
        returnValue = [mUserDefaults integerForKey:SETTINGS_KEY_CURRENT_CLOUDS];
    }
    else if ([key isEqualToString:@"Rain"])
    {
        returnValue = [mUserDefaults integerForKey:SETTINGS_KEY_CURRENT_RAIN];
    }
    else if ([key isEqualToString:@"Snow"])
    {
        returnValue = [mUserDefaults integerForKey:SETTINGS_KEY_CURRENT_SNOW];
    }
    else if ([key isEqualToString:@"Lightning"])
    {
        returnValue = [mUserDefaults boolForKey:SETTINGS_KEY_CURRENT_LIGHTNING];
    }
    else if ([key isEqualToString:@"Fog"])
    {
        returnValue = [mUserDefaults boolForKey:SETTINGS_KEY_CURRENT_FOG];
    }
    else if ([key isEqualToString:@"Season"])
    {
        returnValue = [mUserDefaults integerForKey:SETTINGS_KEY_CURRENT_SEASON];
    }
    return returnValue;
}

- (NSDictionary *)worldOptionForIndexPath:(NSIndexPath *)indexPath
{
    return (NSDictionary *)[[[mTableData objectAtIndex:indexPath.section] valueForKey:@"Rows"] objectAtIndex:indexPath.row];
}

#pragma mark - Settings Load/Save Methods
- (void)saveSettings
{
    if (mOptionsChanged)
    {
        BOOL saveResults = [mUserDefaults synchronize];
        
        if (!saveResults)
        {
            DLog(@"ERROR saving userDefaults!");
        }
        else
        {
            mOptionsChanged = NO;
        }
    }
}

#pragma mark - IBActions
- (IBAction)doneButtonPressed:(id)sender
{
    [self saveSettings];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)switchToggled:(id)sender
{
    UISwitch *cellSwitch = (UISwitch *)sender;
    UITableViewCell *cell = (UITableViewCell *)cellSwitch.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *cellDict = [self worldOptionForIndexPath:indexPath];
    NSString *key = [cellDict valueForKey:@"Header"];
    
    if ([key isEqualToString:@"Location Based"])
    {
        [self locationBasedValueChanged:cellSwitch.isOn];
    }
    else if ([key isEqualToString:@"Fog"])
    {
        // Send message to Game class with weather code for Fog
        [self fogValueChanged:cellSwitch.isOn];
    }
    else if ([key isEqualToString:@"Lightning"])
    {
        // Send message to Game class with weather code for Lightning
        [self lightningValueChanged:cellSwitch.isOn];
    }
//    DLog(@"Changed value of option: %@ to %d", key, cellSwitch.isOn);
}

#pragma mark - SelectWeatherOptionsDelegate Implementation
- (void)willChangeValue:(NSInteger)value forCategory:(WeatherCategory)weatherCategory
{
    switch (weatherCategory) {
        case WeatherCategoryClouds:
        {
            [self cloudsValueChangedRowValue:value];
            break;
        }
        case WeatherCategoryRain:
        {
            [self rainValueChangedWithRowValue:value];
            break;
        }
        case WeatherCategorySnow:
        {
            [self snowValueChangedRowValue:value];
            break;
        }
        case WeatherCategorySeason:
        {
            [self seasonValueChanged:value];
            break;
        }
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - Private Methods
- (void)locationBasedValueChanged:(BOOL)value
{
    [self.delegate controller:self didChangeLocationBased:value];
    [mUserDefaults setBool:value forKey:SETTINGS_KEY_LOCATION_BASED_WEATHER];
    [self googleLogWorldOptionChanged:@"LocationBasedWeather"];
}

- (void)rainValueChangedWithRowValue:(NSUInteger)value
{
    [self.delegate controller:self didChangeRainState:value];
    [mUserDefaults setInteger:value forKey:SETTINGS_KEY_CURRENT_RAIN];
    [self googleLogWorldOptionChanged:@"Rain"];
}

- (void)snowValueChangedRowValue:(NSUInteger)value
{
    [self.delegate controller:self didChangeSnowState:value];
    [mUserDefaults setInteger:value forKey:SETTINGS_KEY_CURRENT_SNOW];
    [self googleLogWorldOptionChanged:@"Snow"];
}

- (void)cloudsValueChangedRowValue:(NSUInteger)value
{
    [self.delegate controller:self didChangeCloudsState:value];
    [mUserDefaults setInteger:value forKey:SETTINGS_KEY_CURRENT_CLOUDS];
    [self googleLogWorldOptionChanged:@"Clouds"];
}

- (void)lightningValueChanged:(BOOL)value
{
    [self.delegate controller:self didChangeLightningState:value];
    [mUserDefaults setBool:value forKey:SETTINGS_KEY_CURRENT_LIGHTNING];
    [self googleLogWorldOptionChanged:@"Lightning"];
}

- (void)fogValueChanged:(BOOL)value
{
    [self.delegate controller:self didChangeFogState:value];
    [mUserDefaults setBool:value forKey:SETTINGS_KEY_CURRENT_FOG];
    [self googleLogWorldOptionChanged:@"Fog"];
}

- (void)seasonValueChanged:(NSInteger)value
{
    [self.delegate controller:self didChangeSeason:value];
    [mUserDefaults setInteger:value forKey:SETTINGS_KEY_CURRENT_SEASON];
    
    [self googleLogWorldOptionChanged:@"Season"];
}

#pragma mark - Analytics Logging Methods
- (void)googleLogWorldOptionChanged:(NSString *)option
{
    if (ANALYTICS_GOOGLE_ON)
    {
        [[GAI sharedInstance].defaultTracker trackEventWithCategory:@"World"
                                                         withAction:[NSString stringWithFormat:@"%@Changed", option]
                                                          withLabel:[NSString stringWithFormat:@"%@Changed", option]
                                                          withValue:[NSNumber numberWithInt:1]];
    }
}
@end
