//
//  EditAlarmRepeatViewController_iPhone.m
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-25.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import "EditAlarmRepeatViewController.h"
#import "Constants.h"

@implementation EditAlarmRepeatViewController

@synthesize repeatBits = _repeatBits;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _repeatBits = 0;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"CELL_TITLE_REPEAT", @"Repeat");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (ANALYTICS_GOOGLE_ON)
        [[GAI sharedInstance].defaultTracker trackView:@"Edit Alarm Repeat"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_delegate didReturnFromEditingAlarmElement:@"repeat" withValue:[NSNumber numberWithInt:_repeatBits]];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row)
    {
            // Title Cell
        case 0:
        {
            cell.textLabel.text = @"Every Sunday";
            break;
        }
        case 1:
        {
            cell.textLabel.text = @"Every Monday";
            break;
        }
        case 2:
        {
            cell.textLabel.text = @"Every Tuesday";
            break;
        }
        case 3:
        {
            cell.textLabel.text = @"Every Wednesday";
            break;
        }
        case 4:
        {
            cell.textLabel.text = @"Every Thursday";
            break;
        }
        case 5:
        {
            cell.textLabel.text = @"Every Friday";
            break;   
        }
        case 6:
        {
            cell.textLabel.text = @"Every Saturday";
            break;                
        }
        default:
            break;
    }
    
    // Check if day_bit 
    if (_repeatBits & (1 << indexPath.row))
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];        
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    NSLog(@"Day value = %d", (_repeatBits >> indexPath.row));
    
    _repeatBits ^= 1 << indexPath.row;
    DLog(@"Day value = %d", (_repeatBits >> indexPath.row));
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma misc - Other Methods
- (void)loadRepeatSchedule:(NSUInteger)repeatBits
{
    self.repeatBits = repeatBits;
}
@end
