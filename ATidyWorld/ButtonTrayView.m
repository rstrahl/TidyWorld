//
//  ButtonsViewController.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-03.
//
//

#import "ButtonTrayView.h"
#import "SettingsTableViewController.h"
#import "WorldOptionsViewController.h"
#import "AlarmListViewController.h"

@interface ButtonTrayView ()
- (void)setupButtons;
/** Presents a content view controller either modally (for iPhone) or as a popover (for iPad)
 *  @param contentViewController the view controller to present
 *  @param sender the sender triggering the presentation (likely a button)
 */
- (void)presentViewController:(UIViewController *)contentViewController fromSender:(id)sender;
/** Delegate method for dismissing the popovercontroller
 *  @param animated YES if the dismissal should be animated, otherwise NO
 */
- (void)dismissPopoverAnimated:(BOOL)animated;
@end

@implementation ButtonTrayView

@synthesize sceneDelegate = mSceneDelegate;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupButtons];
    }
    return self;
}

- (void)setupButtons
{
    // Add Buttons
    // Grab a sample image for a button to obtain the dimensions
    UIImage *weatherImage = [UIImage imageNamed:@"Icon_World.png"];
    UIImage *weatherImageHighlight = [UIImage imageNamed:@"Icon_World_Highlight.png"];
    // Calculate the cell dimensions and padding
    int buttonCount = 0;
    float buttonCellWidth = [[UIScreen mainScreen] bounds].size.width / 3; // width divided by number of buttons
    float buttonCellHorizontalPadding = (buttonCellWidth - weatherImage.size.width) / 2;
    float buttonCellVerticalPadding = (self.frame.size.height / 2) - (weatherImage.size.height / 2);
    CGRect buttonFrame;
    buttonFrame = CGRectMake((buttonCount * buttonCellWidth) + buttonCellHorizontalPadding,
                             buttonCellVerticalPadding,
                             weatherImage.size.width,
                             weatherImage.size.height);
    mChangeWorldButton = [[UIButton alloc] initWithFrame:buttonFrame];
    mChangeWorldButton.alpha = 0.75;
    [mChangeWorldButton setImage:weatherImage forState:UIControlStateNormal];
    [mChangeWorldButton setImage:weatherImageHighlight forState:UIControlStateHighlighted];
    [mChangeWorldButton addTarget:self action:@selector(changeWorldButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mChangeWorldButton];
    buttonCount++;
    
    UIImage *clockImage = [UIImage imageNamed:@"Icon_Clock.png"];
    UIImage *clockHighlightImage = [UIImage imageNamed:@"Icon_Clock_Highlight.png"];
    buttonFrame = CGRectMake((buttonCount * buttonCellWidth) + buttonCellHorizontalPadding,
                             buttonCellVerticalPadding,
                             clockImage.size.width,
                             clockImage.size.height);
    mAlarmClockButton = [[UIButton alloc] initWithFrame:buttonFrame];
    mAlarmClockButton.alpha = 0.75;
    [mAlarmClockButton setImage:clockImage forState:UIControlStateNormal];
    [mAlarmClockButton setImage:clockHighlightImage forState:UIControlStateHighlighted];
    [mAlarmClockButton addTarget:self action:@selector(alarmClockButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mAlarmClockButton];
    buttonCount++;
    
    UIImage *settingsImage = [UIImage imageNamed:@"Icon_Settings.png"];
    UIImage *settingsHighlightImage = [UIImage imageNamed:@"Icon_Settings_Highlight.png"];
    buttonFrame = CGRectMake((buttonCount * buttonCellWidth) + buttonCellHorizontalPadding,
                             buttonCellVerticalPadding,
                             clockImage.size.width,
                             clockImage.size.height);
    mSettingsButton = [[UIButton alloc] initWithFrame:buttonFrame];
    mSettingsButton.alpha = 0.75;
    [mSettingsButton setImage:settingsImage forState:UIControlStateNormal];
    [mSettingsButton setImage:settingsHighlightImage forState:UIControlStateHighlighted];
    [mSettingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mSettingsButton];
}

#pragma mark - Button Actions
- (void)alarmClockButtonPressed:(id)sender
{
    DLog(@"");
    AlarmListViewController *alarmListViewController = [[AlarmListViewController alloc] init];
    alarmListViewController.delegate = self;
    [self presentViewController:alarmListViewController fromSender:sender];
}

- (void)changeSeasonButtonPressed:(id)sender
{
    DLog(@"");
}

- (void)changeWorldButtonPressed:(id)sender
{
    DLog(@"");
    WorldOptionsViewController *worldOptionsViewController = [[WorldOptionsViewController alloc] initWithNibName:@"WorldOptionsViewController" bundle:nil];
    worldOptionsViewController.delegate = self;
    [self presentViewController:worldOptionsViewController fromSender:sender];
}

- (void)settingsButtonPressed:(id)sender
{
    DLog(@"");
    SettingsTableViewController *settingsViewController = [[SettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingsViewController.delegate = self;
    [self presentViewController:settingsViewController fromSender:sender];
}

- (void)presentViewController:(UIViewController *)contentViewController fromSender:(id)sender
{
    UIButton *senderButton = (UIButton *)sender;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    navController.contentSizeForViewInPopover = CGSizeMake(320,436);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
        [self.popoverController presentPopoverFromRect:senderButton.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self.parentViewController presentModalViewController:navController animated:YES];
    }
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
    [self.popoverController dismissPopoverAnimated:animated];
}

#pragma mark - WorldOptionsDelegate Implementation
- (void)controller:(WorldOptionsViewController *)controller didChangeWeatherConditions:(WeatherCondition)condition
{
    [self.sceneDelegate controller:controller didChangeWeatherConditions:condition];
}

- (void)controller:(WorldOptionsViewController *)controller didChangeLocationBased:(BOOL)isLocationBased
{
    [self.sceneDelegate controller:controller didChangeLocationBased:isLocationBased];
}

- (void)controller:(WorldOptionsViewController *)controller didChangeSeason:(NSUInteger)season
{
    [self.sceneDelegate controller:controller didChangeSeason:season];
}

@end
