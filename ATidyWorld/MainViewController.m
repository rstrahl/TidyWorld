//
//  MainViewController.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-26.
//
//

#import "MainViewController.h"
#import "ClockFaceView.h"
#import "ButtonTrayView.h"
#import "AdsViewController.h"
#import "AppDelegate.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize buttonsView = mButtonsView,
            clockView = mClockView,
            adsViewController = mAdsViewController,
            buttonsHighAlphaTimer = mButtonsHighAlphaTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat sizeMultiplier = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) ? 2.0 : 1.0;
        
        // Add Clock Label
        CGRect clockFaceFrame = CGRectMake(0,
                                           0,
                                           screenSize.width,
                                           80*sizeMultiplier);
        mClockView = [[ClockFaceView alloc] initWithFrame:clockFaceFrame];
        [self.view addSubview:mClockView];
        
        // Add ButtonsViewControlller
        mButtonsView = [[ButtonTrayView alloc] initWithFrame:CGRectMake(screenSize.width,
                                                                        0,
                                                                        screenSize.width,
                                                                        80*sizeMultiplier)];
        mButtonsView.parentViewController = self;
        mButtonsView.hidden = YES;
        [self.view addSubview:mButtonsView];
        
        // Add navigation buttons (left/right)
        UIImage *leftImage = [UIImage imageNamed:@"Icon_LeftArrow.png"];
        UIImage *leftImageHighlighted = [UIImage imageNamed:@"Icon_LeftArrow_Highlight.png"];
        mLeftNavigationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mLeftNavigationButton.hidden = YES;
        mLeftNavigationButton.alpha = 0;
        [mLeftNavigationButton addTarget:self
                                  action:@selector(leftNavigationButtonPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
        [mLeftNavigationButton setImage:leftImage forState:UIControlStateNormal];
        [mLeftNavigationButton setImage:leftImageHighlighted forState:UIControlStateHighlighted];
        mLeftNavigationButton.frame = CGRectMake(8,
                                                 ((80 * sizeMultiplier) / 2) - (leftImage.size.width / 2),
                                                 leftImage.size.width,
                                                 leftImage.size.height);
        [self.view addSubview:mLeftNavigationButton];
        
        UIImage *rightImage = [UIImage imageNamed:@"Icon_RightArrow.png"];
        UIImage *rightImageHighlighted = [UIImage imageNamed:@"Icon_RightArrow_Highlight.png"];
        mRightNavigationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mRightNavigationButton.hidden = NO;
        mRightNavigationButton.alpha = 0.5;
        [mRightNavigationButton addTarget:self
                                   action:@selector(rightNavigationButtonPressed:)
                         forControlEvents:UIControlEventTouchUpInside];
        [mRightNavigationButton setImage:rightImage forState:UIControlStateNormal];
        [mRightNavigationButton setImage:rightImageHighlighted forState:UIControlStateHighlighted];
        mRightNavigationButton.frame = CGRectMake(screenSize.width - rightImage.size.width - 8,
                                                  ((80 * sizeMultiplier) / 2) - (rightImage.size.width / 2),
                                                  rightImage.size.width,
                                                  rightImage.size.height);
        [self.view addSubview:mRightNavigationButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Add AdsViewController
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSceneDelegate:(id)sceneDelegate
{
    mSceneDelegate = sceneDelegate;
    mButtonsView.sceneDelegate = sceneDelegate;
}

#pragma mark - IBActions
- (IBAction)leftNavigationButtonPressed:(id)sender
{
    DLog(@"");
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (mClockView.hidden)
    {
        mRightNavigationButton.hidden = NO;
        mClockView.hidden = NO;
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             mButtonsView.frame = CGRectOffset(mButtonsView.frame, +screenSize.width, 0);
                             mClockView.frame = CGRectOffset(mClockView.frame, +screenSize.width, 0);
                             mLeftNavigationButton.alpha = 0;
                             mRightNavigationButton.alpha = 0.5;
                         }
                         completion:^(BOOL finished) {
                             mButtonsView.hidden = YES;
                             mLeftNavigationButton.hidden = YES;
                         }
         ];
    }
}

- (IBAction)rightNavigationButtonPressed:(id)sender
{
    DLog(@"");
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (mButtonsView.hidden)
    {
        mLeftNavigationButton.hidden = NO;
        mButtonsView.hidden = NO;
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             mButtonsView.frame = CGRectOffset(mButtonsView.frame, -screenSize.width, 0);
                             mClockView.frame = CGRectOffset(mClockView.frame, -screenSize.width, 0);
                             mRightNavigationButton.alpha = 0;
                             mLeftNavigationButton.alpha = 0.5;
                         }
                         completion:^(BOOL finished) {
                             mClockView.hidden = YES;
                             mRightNavigationButton.hidden = YES;
                         }
         ];
    }
}

#pragma mark - UIView Animations
- (void)fadeOutButtons
{
    DLog(@"");
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         mButtonsView.alpha = 0.5;
                     }
                     completion:^(BOOL finished) {
                         mClockView.hidden = YES;
                         mRightNavigationButton.hidden = YES;
                     }
     ];
}

- (void)fadeInButtons
{
    DLog(@"");
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         mButtonsView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         mClockView.hidden = YES;
                         mRightNavigationButton.hidden = YES;
                     }
     ];

}

#pragma mark - Test
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
//    if (self.buttonsHighAlphaTimer != nil)
//    {
//        if ([self.buttonsHighAlphaTimer isValid])
//        {
//            [self.buttonsHighAlphaTimer invalidate];
//            self.buttonsHighAlphaTimer = nil;
//        }
//    }
//    [self fadeInButtons];
    DLog(@"");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    // Set NSTimer for 5-10 seconds that unless interrupted will fade out all non-hidden buttons to MINALPHA
//    self.buttonsHighAlphaTimer = [NSTimer scheduledTimerWithTimeInterval:5
//                                                              target:self
//                                                            selector:@selector(fadeOutButtons)
//                                                            userInfo:nil
//                                                             repeats:NO];
    DLog(@"");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    DLog(@"");
}

@end