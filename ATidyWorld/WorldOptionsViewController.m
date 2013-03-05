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
- (void)addSwitchToCell:(UITableViewCell *)cell forKey:(NSString *)key enabled:(BOOL)enabled;
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
 
    NSString *filePath = [[NSBundle mainBundle] bundlePath];
    NSString *dataPath = [filePath stringByAppendingPathComponent:@"WorldOptions.plist"];
    
    mTableData = [[NSArray alloc] initWithContentsOfFile:dataPath];
    
    mUserDefaults = [NSUserDefaults standardUserDefaults];
    mCurrentWeatherCondition.clouds = [mUserDefaults integerForKey:SETTINGS_KEY_CURRENT_CLOUDS];
    mCurrentWeatherCondition.rain = [mUserDefaults integerForKey:SETTINGS_KEY_CURRENT_RAIN];
    mCurrentWeatherCondition.snow = [mUserDefaults integerForKey:SETTINGS_KEY_CURRENT_SNOW];
    mCurrentWeatherCondition.fog = [mUserDefaults boolForKey:SETTINGS_KEY_CURRENT_FOG];
    mCurrentWeatherCondition.lightning = [mUserDefaults boolForKey:SETTINGS_KEY_CURRENT_LIGHTNING];
    mCurrentWeatherCondition.season = [mUserDefaults integerForKey:SETTINGS_KEY_CURRENT_SEASON];
    mLocationBasedWeather = [mUserDefaults boolForKey:SETTINGS_KEY_LOCATION_BASED_WEATHER];
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
    if ([key isEqualToString:@"Location Based"])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSwitchToCell:cell forKey:key enabled:YES];
    }
    else if ([key isEqualToString:@"Fog"] ||
             [key isEqualToString:@"Lightning"])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (mLocationBasedWeather)
        {
            cell.textLabel.enabled = NO;
            [self addSwitchToCell:cell forKey:key enabled:NO];
        }
        else
        {
            cell.textLabel.enabled = YES;
            [self addSwitchToCell:cell forKey:key enabled:YES];
        }
    }
    // Handle multiple-choice World Options
    else
    {
        cell.detailTextLabel.text = [[cellDict valueForKey:@"Rows"] objectAtIndex:[self currentValueForWeatherOptionKey:key]];
        if (mLocationBasedWeather)
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            cell.userInteractionEnabled = NO;
            cell.textLabel.enabled = NO;
            cell.detailTextLabel.enabled = NO;
        }
        else
        {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.userInteractionEnabled = YES;
            cell.textLabel.enabled = YES;
            cell.detailTextLabel.enabled = YES;
        }
    
    }
}
- (void)addSwitchToCell:(UITableViewCell *)cell forKey:(NSString *)key enabled:(BOOL)enabled
{
    UISwitch *cellSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [cellSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    [cell setAccessoryView:cellSwitch];
    [cellSwitch setOn:[self currentValueForWeatherOptionKey:key]];
    cellSwitch.enabled = enabled;
    if ([key isEqualToString:@"Lightning"])
    {
        self.lightningSwitch = cellSwitch;
        if (mCurrentWeatherCondition.clouds == WeatherCloudsNone)
        {
            cellSwitch.enabled = NO;
        }
    }
}

- (NSInteger)currentValueForWeatherOptionKey:(NSString *)key
{
    NSInteger returnValue = 0;
    if ([key isEqualToString:@"Clouds"])
    {
        returnValue = mCurrentWeatherCondition.clouds;
    }
    else if ([key isEqualToString:@"Rain"])
    {
        returnValue = mCurrentWeatherCondition.rain;
    }
    else if ([key isEqualToString:@"Snow"])
    {
        returnValue = mCurrentWeatherCondition.snow;
    }
    else if ([key isEqualToString:@"Lightning"])
    {
        returnValue = mCurrentWeatherCondition.lightning;
    }
    else if ([key isEqualToString:@"Fog"])
    {
        returnValue = mCurrentWeatherCondition.fog;
    }
    else if ([key isEqualToString:@"Season"])
    {
        returnValue = mCurrentWeatherCondition.season;
    }
    else if ([key isEqualToString:@"Location Based"])
    {
        returnValue = mLocationBasedWeather;
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
        [mUserDefaults setBool:mLocationBasedWeather forKey:SETTINGS_KEY_LOCATION_BASED_WEATHER];
        [mUserDefaults setInteger:mCurrentWeatherCondition.clouds forKey:SETTINGS_KEY_CURRENT_CLOUDS];
        [mUserDefaults setInteger:mCurrentWeatherCondition.rain forKey:SETTINGS_KEY_CURRENT_RAIN];
        [mUserDefaults setInteger:mCurrentWeatherCondition.snow forKey:SETTINGS_KEY_CURRENT_SNOW];
        [mUserDefaults setBool:mCurrentWeatherCondition.fog forKey:SETTINGS_KEY_CURRENT_FOG];
        [mUserDefaults setBool:mCurrentWeatherCondition.lightning forKey:SETTINGS_KEY_CURRENT_LIGHTNING];
        [mUserDefaults setInteger:mCurrentWeatherCondition.season forKey:SETTINGS_KEY_CURRENT_SEASON];
        
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
        mCurrentWeatherCondition.fog = cellSwitch.isOn;
        [self didChangeWeatherCondition:key];
    }
    else if ([key isEqualToString:@"Lightning"])
    {
        mCurrentWeatherCondition.lightning = cellSwitch.isOn;
        [self didChangeWeatherCondition:key];
    }
}

#pragma mark - SelectWeatherOptionsDelegate Implementation
- (void)willChangeValue:(NSInteger)value forCategory:(WeatherCategory)weatherCategory
{
    NSString *category = nil;
    switch (weatherCategory) {
        case WeatherCategoryClouds:
        {
            mCurrentWeatherCondition.clouds = value;
            if (mCurrentWeatherCondition.clouds == WeatherCloudsNone)
            {
                [self.lightningSwitch setOn:NO];
                mCurrentWeatherCondition.lightning = WeatherLightningNone;
            }
            category = @"Clouds";
            break;
        }
        case WeatherCategoryRain:
        {
            mCurrentWeatherCondition.rain = value;
            category = @"Rain";
            break;
        }
        case WeatherCategorySnow:
        {
            mCurrentWeatherCondition.snow = value;
            category = @"Snow";
            break;
        }
        case WeatherCategorySeason:
        {
            mCurrentWeatherCondition.season = value;
            category = @"Season";
            break;
        }
        default:
            break;
    }
    [self didChangeWeatherCondition:category];
    [self.tableView reloadData];
}

#pragma mark - Private Methods
- (void)didChangeWeatherCondition:(NSString *)weatherConditionKey
{
    mOptionsChanged = YES;
    [self locationBasedValueChanged:NO];
    [self.tableView reloadData];
    [self.delegate controller:self didChangeWeatherConditions:mCurrentWeatherCondition];
    [self googleLogWorldOptionChanged:weatherConditionKey];
}

- (void)rainValueChangedWithRowValue:(NSUInteger)value
{
    mCurrentWeatherCondition.rain = value;
    [self.delegate controller:self didChangeWeatherConditions:mCurrentWeatherCondition];
    [self googleLogWorldOptionChanged:@"Rain"];
}

- (void)snowValueChangedRowValue:(NSUInteger)value
{
    mCurrentWeatherCondition.snow = value;
    [self.delegate controller:self didChangeWeatherConditions:mCurrentWeatherCondition];
    [self googleLogWorldOptionChanged:@"Snow"];
}

- (void)cloudsValueChangedRowValue:(NSUInteger)value
{
    mCurrentWeatherCondition.clouds = value;
    [self.delegate controller:self didChangeWeatherConditions:mCurrentWeatherCondition];
    [self googleLogWorldOptionChanged:@"Clouds"];
}

- (void)lightningValueChanged:(BOOL)value
{
    mCurrentWeatherCondition.lightning = value;
    [self.delegate controller:self didChangeWeatherConditions:mCurrentWeatherCondition];
    [self googleLogWorldOptionChanged:@"Lightning"];
}

- (void)fogValueChanged:(BOOL)value
{
    mCurrentWeatherCondition.fog = value;
    [self.delegate controller:self didChangeWeatherConditions:mCurrentWeatherCondition];
    [self googleLogWorldOptionChanged:@"Fog"];
}

- (void)seasonValueChanged:(NSInteger)value
{
    [self.delegate controller:self didChangeSeason:value];
    [mUserDefaults setInteger:value forKey:SETTINGS_KEY_CURRENT_SEASON];
    [self googleLogWorldOptionChanged:@"Season"];
}

- (void)locationBasedValueChanged:(BOOL)value
{
    mOptionsChanged = YES;
    mLocationBasedWeather = value;
    [self.tableView reloadData];
    [self.delegate controller:self didChangeLocationBased:mLocationBasedWeather];
    [self googleLogWorldOptionChanged:@"Location Based Weather"];
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
