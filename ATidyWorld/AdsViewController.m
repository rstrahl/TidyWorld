//
//  AdsViewController.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-01-31.
//
//

#import "AdsViewController.h"
#import "Constants.h"
#import <AdSupport/AdSupport.h>

@interface AdsViewController ()
- (void)initIadBannerView;
- (void)initAdMobBannerView;
@end

@implementation AdsViewController

@synthesize iAdBannerView = mIadBannerView,
            adMobBannerView = mAdMobBannerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Print IDFA (from AdSupport Framework) for iOS 6 and UDID for iOS < 6.
        if (NSClassFromString(@"ASIdentifierManager")) {
            NSLog(@"GoogleAdMobAdsSDK ID for testing: %@" ,
                  [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]);
        } else {
            NSLog(@"GoogleAdMobAdsSDK ID for testing: %@" ,
                  [[UIDevice currentDevice] uniqueIdentifier]);
        }
        
        CGRect viewFrame;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            viewFrame = CGRectMake(0,
                                   [[UIScreen mainScreen] bounds].size.height-90,
                                   [[UIScreen mainScreen] bounds].size.width,
                                   90);
        }
        else
        {
            viewFrame = CGRectMake(0,
                                   [[UIScreen mainScreen] bounds].size.height-50,
                                   [[UIScreen mainScreen] bounds].size.width,
                                   50);            
        }
        UIView *view = [[UIView alloc] initWithFrame:viewFrame];
        view.backgroundColor = [UIColor whiteColor];
        view.alpha = 0.25f;
        self.view = view;
        [view release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initIadBannerView];
    [self initAdMobBannerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [mIadBannerView release];
    [mAdMobBannerView release];
    [super dealloc];
}

#pragma mark - AdBannerViewDelegate (iAd) Implementation
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    banner.hidden = NO;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    banner.hidden = YES;
    
    // Only request adMob when iAd fails
    GADRequest *request = [GADRequest request];
    // Make the request for a test ad. Put in an identifier for
    // the simulator as well as any devices you want to receive test ads.
    request.testDevices = [NSArray arrayWithObjects:
                           ADMOB_SIMULATOR_IDENTIFIER1, nil];
    [self.adMobBannerView loadRequest:request];
    [self hideBanner:self.iAdBannerView];
    [self showBanner:self.adMobBannerView];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    // TODO: Instruct game to halt
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    // TODO: Instruct game to continue
}


#pragma mark - GADBannerViewDelegate (AdMob) Implementation
- (void)adViewDidReceiveAd:(GADBannerView *)banner
{
    DLog(@"");
    if ([self.iAdBannerView isHidden])
    {
        [self showBanner:banner];
    }
}

- (void)adView:(GADBannerView *)banner didFailToReceiveAdWithError:(GADRequestError *)error;
{
    DLog(@"");
    [self hideBanner:banner];
}

#pragma mark - Advertising Initialization
- (void)initIadBannerView
{
    // iAd Banner View (shouldn't appear in paid version)
    if (!mIadBannerView)
    {
        mIadBannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
        mIadBannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, nil];
        mIadBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        mIadBannerView.delegate = self;
        CGRect adViewFrame = mIadBannerView.frame;
        mIadBannerView.frame = adViewFrame;
        [self.view addSubview:mIadBannerView];
    }
}

-(void)initAdMobBannerView
{
    if (!mAdMobBannerView)
    {
        // Create a new bottom banner, will be slided into view
        mAdMobBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        mAdMobBannerView.adUnitID = ADMOB_PUBLISHER_ID;
        mAdMobBannerView.hidden = TRUE;
        mAdMobBannerView.rootViewController = self;
        [self.view addSubview:mAdMobBannerView];
    }
}

- (void)showBanner:(UIView *)banner
{
    if (banner &&
        [banner isHidden])
    {
        self.view.alpha = 1.0f;
        [UIView beginAnimations:@"animatedBannerOn" context:nil];
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        banner.hidden = FALSE;
    }
}

- (void)hideBanner:(UIView *)banner
{
    if (banner &&
        ![banner isHidden])
    {
        self.view.alpha = 0.25f;
        [UIView beginAnimations:@"animatedBannerOff" context:nil];
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        banner.hidden = TRUE;
    }
}

// DEBUG ONLY
- (void)toggleAdMobBannerView
{
    if (!self.iAdBannerView.isHidden)
    {
        [self toggleIadBannerView];
    }
    if (mAdMobBannerView.isHidden)
    {
        [self showBanner:self.adMobBannerView];
    }
    else
    {
        [self hideBanner:self.adMobBannerView];
    }
}
// DEBUG ONLY
- (void)toggleIadBannerView
{
    if (!self.adMobBannerView.isHidden)
    {
        [self toggleAdMobBannerView];
    }
    if (mAdMobBannerView.isHidden)
    {
        [self showBanner:self.adMobBannerView];
    }
    else
    {
        [self hideBanner:self.adMobBannerView];
    }
}

//#pragma mark - AdMob Methods
//- (void)requestAdMob
//{
//    // Only request adMob when iAd fails
//    GADRequest *request = [GADRequest request];
//
//#ifdef DEBUG
//    request.testDevices = [NSArray arrayWithObjects:@"C77C7F9F-63D0-5BF4-820F-7084658E8B79", nil];
//    [self showBanner:self.adMobBannerView];
//#endif
//
//    [self.adMobBannerView loadRequest:request];
//
//    Game *game = (Game *)[mSparrowView.stage childAtIndex:0];
//    [game adVisible:NO];
//}


@end
