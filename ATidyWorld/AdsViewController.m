//
//  AdsViewController.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-01-31.
//
//

#import "AdsViewController.h"
#import "Constants.h"
#import "LocationService.h"
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
        
//        CGRect viewFrame;
//        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//        {
//            viewFrame = CGRectMake(0,
//                                   [[UIScreen mainScreen] bounds].size.height-90,
//                                   [[UIScreen mainScreen] bounds].size.width,
//                                   90);
//        }
//        else
//        {
//            viewFrame = CGRectMake(0,
//                                   [[UIScreen mainScreen] bounds].size.height-50,
//                                   [[UIScreen mainScreen] bounds].size.width,
//                                   50);            
//        }
//        UIView *view = [[UIView alloc] initWithFrame:viewFrame];
//        view.backgroundColor = [UIColor clearColor];
////        view.alpha = 0.25f;
//        self.view = view;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect viewFrame;
    DLog(@"Screen bounds for ads: %f x %f", [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
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
    self.view.frame = viewFrame;
    if (USE_IAD)
    {
        [self initIadBannerView];
    }
    [self initAdMobBannerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
        mAdMobBannerView.hidden = !USE_IAD; // If we are using IAD, then the IAD will be given preference
        mAdMobBannerView.rootViewController = self;
        mAdMobBannerView.delegate = self;
        [self.view addSubview:mAdMobBannerView];
        [self willRequestAd];
    }
}

- (void)showBanner:(UIView *)banner
{
    if (banner &&
        [banner isHidden])
    {
        [UIView beginAnimations:@"animatedBannerOn" context:nil];
        self.view.alpha = 1.0f;
//        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        banner.hidden = FALSE;
    }
}

- (void)hideBanner:(UIView *)banner
{
    if (banner &&
        ![banner isHidden])
    {
        [UIView beginAnimations:@"animatedBannerOff" context:nil];
        self.view.alpha = 0.0f;
//        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
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

- (void)willRequestAd
{
    if (!USE_IAD)
    {
        [self requestAdMob];
    }
}

//#pragma mark - AdMob Methods
- (void)requestAdMob
{
    // Only request adMob when iAd fails
    GADRequest *request = [GADRequest request];
    LocationService *location = [LocationService sharedInstance];
    if (location.currentLocation != nil)
    {
        [request setLocationWithLatitude:location.currentLocation.coordinate.latitude
                               longitude:location.currentLocation.coordinate.longitude
                                accuracy:location.currentLocation.horizontalAccuracy];
    }
    [self showBanner:self.adMobBannerView];
    [self.adMobBannerView loadRequest:request];
}


@end
