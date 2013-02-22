//
//  ButtonsViewController.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-03.
//
//

#import "ButtonsViewController.h"
#import "SettingsTableViewController.h"
#import "WorldOptionsViewController.h"
#import "AlarmListViewController.h"

@interface ButtonsViewController ()

@end

@implementation ButtonsViewController

@synthesize delegate = mDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Add Buttons
    // Grab a sample image for a button to obtain the dimensions
    UIImage *weatherImage = [UIImage imageNamed:@"Icon_World.png"];
    UIImage *weatherImageHighlight = [UIImage imageNamed:@"Icon_World_Highlight.png"];
    // Calculate the cell dimensions and padding
    int buttonCount = 0;
    float buttonCellWidth = [[UIScreen mainScreen] bounds].size.width / 4; // width divided by number of buttons
    float buttonCellPadding = (buttonCellWidth - weatherImage.size.width) / 2;
    CGRect buttonFrame;
    buttonFrame = CGRectMake((buttonCount * buttonCellWidth) + buttonCellPadding,
                             buttonCellPadding,
                             weatherImage.size.width,
                             weatherImage.size.height);
    mChangeWorldButton = [[UIButton alloc] initWithFrame:buttonFrame];
    mChangeWorldButton.alpha = 0.75;
    [mChangeWorldButton setImage:weatherImage forState:UIControlStateNormal];
    [mChangeWorldButton setImage:weatherImageHighlight forState:UIControlStateHighlighted];
    [mChangeWorldButton addTarget:self action:@selector(changeWorldButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mChangeWorldButton];
    buttonCount++;
    
    UIImage *clockImage = [UIImage imageNamed:@"Icon_Clock.png"];
    UIImage *clockHighlightImage = [UIImage imageNamed:@"Icon_Clock_Highlight.png"];
    buttonFrame = CGRectMake((buttonCount * buttonCellWidth) + buttonCellPadding,
                             buttonCellPadding,
                             clockImage.size.width,
                             clockImage.size.height);
    mAlarmClockButton = [[UIButton alloc] initWithFrame:buttonFrame];
    mAlarmClockButton.alpha = 0.75;
    [mAlarmClockButton setImage:clockImage forState:UIControlStateNormal];
    [mAlarmClockButton setImage:clockHighlightImage forState:UIControlStateHighlighted];
    [mAlarmClockButton addTarget:self action:@selector(alarmClockButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mAlarmClockButton];
    buttonCount++;
    
    UIImage *settingsImage = [UIImage imageNamed:@"Icon_Settings.png"];
    UIImage *settingsHighlightImage = [UIImage imageNamed:@"Icon_Settings_Highlight.png"];
    buttonFrame = CGRectMake((buttonCount * buttonCellWidth) + buttonCellPadding,
                             buttonCellPadding,
                             clockImage.size.width,
                             clockImage.size.height);
    mSettingsButton = [[UIButton alloc] initWithFrame:buttonFrame];
    mSettingsButton.alpha = 0.75;
    [mSettingsButton setImage:settingsImage forState:UIControlStateNormal];
    [mSettingsButton setImage:settingsHighlightImage forState:UIControlStateHighlighted];
    [mSettingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mSettingsButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions
- (void)alarmClockButtonPressed:(id)sender
{
    DLog(@"");
    AlarmListViewController *alarmListViewController = [[AlarmListViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:alarmListViewController];
    [self presentModalViewController:navController animated:YES];
}

- (void)changeSeasonButtonPressed:(id)sender
{
    DLog(@"");
}

- (void)changeWorldButtonPressed:(id)sender
{
    DLog(@"");
    WorldOptionsViewController *worldOptionsViewController = [[WorldOptionsViewController alloc] initWithNibName:@"WorldOptionsViewController" bundle:nil];
    worldOptionsViewController.delegate = self.delegate;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:worldOptionsViewController];
    [self presentModalViewController:navController animated:YES];
}

- (void)settingsButtonPressed:(id)sender
{
    DLog(@"");
    SettingsTableViewController *settingsViewController = [[SettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [self presentModalViewController:navController animated:YES];
}

@end
