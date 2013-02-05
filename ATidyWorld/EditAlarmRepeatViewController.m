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
    if (self) {
        // Custom initialization
        _repeatBits = 0;
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
    self.title = NSLocalizedString(@"CELL_TITLE_REPEAT", @"Repeat");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (ANALYTICS_GOOGLE_ON)
        [[GAI sharedInstance].defaultTracker trackView:@"Edit Alarm Repeat"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_delegate didReturnFromEditingAlarmElement:@"repeat" withValue:[NSNumber numberWithInt:_repeatBits]];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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

// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return NO;
//}

// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
    
    
//    BOOL daySet = [[_dayArray objectAtIndex:indexPath.row] boolValue];
//    [_dayArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:!daySet]];
//    NSMutableString *dayString = [NSMutableString stringWithCapacity:0];
//    for (NSNumber *daySet in _dayArray)
//    {
//        [dayString appendFormat:@"%@, ", daySet];
//    }
    NSLog(@"Day value = %d", (_repeatBits >> indexPath.row));
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 70;
//}

#pragma misc - Other Methods
- (void)loadRepeatSchedule:(NSUInteger)repeatBits
{
    self.repeatBits = repeatBits;
}
@end
