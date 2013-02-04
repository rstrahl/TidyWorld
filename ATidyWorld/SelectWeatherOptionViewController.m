//
//  SelectWeatherOptionViewController.m
//  TidyTime
//
//  Created by Rudi Strahl on 2012-10-15.
//
//

#import "SelectWeatherOptionViewController.h"
#import "Constants.h"

@interface SelectWeatherOptionViewController ()

@end

@implementation SelectWeatherOptionViewController

@synthesize tableData = mTableData,
            weatherCategory = mWeatherCategory,
            checkedRow = mCheckedRow,
            optionWasChanged = mOptionWasChanged,
            lastIndexPath = mLastIndexPath,
            weatherOptionDelegate = mWeatherOptionDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    mOptionWasChanged = NO;
    [super viewWillAppear:animated];
    if (ANALYTICS_GOOGLE_ON)
    {
        [[GAI sharedInstance].defaultTracker trackView:[NSString stringWithFormat:@"World Options - %@", self.title]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.optionWasChanged)
    {
        [self.weatherOptionDelegate willChangeValue:mCheckedRow forCategory:mWeatherCategory];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource Implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self.tableData valueForKey:@"Header"] isEqualToString:@"Temperature"])
    {
        return 1;
    }
    else
    {
        return [[self.tableData valueForKey:@"Rows"] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.tableData valueForKey:@"Header"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureWeatherOptionCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate Implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.lastIndexPath isEqual:indexPath])
    {
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:mLastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.lastIndexPath = indexPath;
        self.checkedRow = indexPath.row;
        mOptionWasChanged = YES;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewCell Configurations
- (UITableViewCell *)configureWeatherOptionCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    cell.textLabel.text = [[mTableData valueForKey:@"Rows"] objectAtIndex:indexPath.row];
    if (self.checkedRow == indexPath.row)
    {
        if (mLastIndexPath == nil)
        {
            self.lastIndexPath = indexPath;
        }
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

@end
