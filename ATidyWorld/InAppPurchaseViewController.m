//
//  InAppPurchaseViewController.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-04-09.
//
//

#import "InAppPurchaseViewController.h"
#import "TMInAppPurchaseHelper.h"
#import "TMActivityInProgressView.h"
#import "Reachability.h"

@interface InAppPurchaseViewController ()

@end

@implementation InAppPurchaseViewController

@synthesize activityProgressView = _activityProgressView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"VIEW_TITLE_INAPP_PURCHASES", @"In-App Purchases");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.activityProgressView = [[TMActivityInProgressView alloc] initWithFrame:self.view.frame];
    [self.activityProgressView hideView];
}

- (void)viewWillAppear:(BOOL)animated
{    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveProductsLoadedNotification:)
                                                 name:TM_PRODUCTS_LOADED_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased:)
                                                 name:TM_PRODUCT_PURCHASED_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(productPurchaseFailed:)
                                                 name:TM_PRODUCT_PURCHASE_FAILED_NOTIFICATION
                                               object: nil];
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable)
    {
        NSLog(@"No internet connection!");
    }
    else
    {
        if ([TMInAppPurchaseHelper sharedHelper].products == nil)
        {
            [self.tableView setTableHeaderView:self.activityProgressView];
            [self.activityProgressView showView];
            [self.activityProgressView.messageLabel setText:NSLocalizedString(@"ACTIVITY_TEXT_LOADING_PRODUCTS", @"Loading Products")];
            [self performSelector:@selector(requestTimedOut:) withObject:nil afterDelay:30.0];
            [[TMInAppPurchaseHelper sharedHelper] requestProducts];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[TMInAppPurchaseHelper sharedHelper].products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    SKProduct *product = [[TMInAppPurchaseHelper sharedHelper].products objectAtIndex:indexPath.row];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = formattedString;
    
    if ([[TMInAppPurchaseHelper sharedHelper].purchasedProducts containsObject:product.productIdentifier])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    }
    else
    {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buyButton.frame = CGRectMake(0, 0, 72, 37);
        [buyButton setTitle:NSLocalizedString(@"BUTTON_TITLE_BUY", @"Buy") forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;     
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - Purchase Loading
- (void)progressIndicatorTimedOut
{
    
}

- (void)didReceiveProductsLoadedNotification:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.activityProgressView hideView];
    [self.tableView setTableHeaderView:nil];
    [self.tableView setHidden:NO];
    [self.tableView reloadData];    
}

- (void)requestTimedOut:(id)arg
{
    // TODO: Display alertview indicating the request timed out and try again later
}

#pragma mark - Purchase Handling
- (IBAction)buyButtonPressed:(id)sender
{
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = [[TMInAppPurchaseHelper sharedHelper].products objectAtIndex:buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[TMInAppPurchaseHelper sharedHelper] buyProductIdentifier:product.productIdentifier];
    
    // TODO: Show progress indicator view informing user that the purchase is being made
    [self performSelector:@selector(progressIndicatorTimedOut:) withObject:nil afterDelay:60*5];
}

- (void)productPurchaseFailed:(NSNotification *)notification
{    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    // TODO: Hide progress indicator view
    
    SKPaymentTransaction *transaction = (SKPaymentTransaction *)notification.object;
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"ALERT_VIEW_INAPP_PURCHASE_ERROR_TITLE"
                                                         message:transaction.error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil] autorelease];
        
        [alert show];
    }
}

@end
