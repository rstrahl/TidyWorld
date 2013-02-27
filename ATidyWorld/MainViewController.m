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

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize buttonsView = mButtonsView,
            clockView = mClockView,
            sceneDelegate = mSceneDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Add Clock Label
        CGSize screenSize = [UIScreen mainScreen].bounds.size;

        CGRect clockFaceFrame = CGRectMake((screenSize.width / 2) - (300 / 2),
                                           0,
                                           300,
                                           80);
        mClockView = [[ClockFaceView alloc] initWithFrame:clockFaceFrame];
        
        // Add ButtonsViewControlller
        mButtonsView = [[ButtonTrayView alloc] initWithFrame:CGRectMake(screenSize.width,
                                                                        0,
                                                                        screenSize.width,
                                                                        80)];
        mButtonsView.sceneDelegate = self.sceneDelegate;
        mButtonsView.parentViewController = self;
        
        mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     [UIScreen mainScreen].bounds.size.width,
                                                                     80)];
        [mScrollView addSubview:mClockView];
        [mScrollView addSubview:mButtonsView];
        [mScrollView setContentSize:CGSizeMake(mScrollView.frame.size.width * 2, 80)];
        [mScrollView setPagingEnabled:YES];
        
        [self.view addSubview:mScrollView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Test
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    DLog(@"");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    DLog(@"");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    DLog(@"");
}

@end