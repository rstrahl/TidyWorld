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
#import "cocos2d.h"

@interface AdsViewController ()
/** Initialize Apple iAd Bannerview */
- (void)initIadBannerView;
/** Initialize Google AdMob Bannerview */
- (void)initAdMobBannerView;
/** Fade-in animation for presenting a bannerView */
- (void)showBanner:(UIView *)banner;
/** Fade-out animation for removing a bannerView */
- (void)hideBanner:(UIView *)banner;
/** Sets the frame of the bannerview */
- (CGRect)setFrame;
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
//          view.alpha = 0.25f;
//        self.view = view;
        NSTimer *refreshAdTimer = [NSTimer scheduledTimerWithTimeInterval:AD_REFRESH_RATE
                                                                   target:self
                                                                 selector:@selector(willRequestAd)
                                                                 userInfo:nil
                                                                  repeats:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = [self setFrame];
    self.view.hidden = NO;
#ifdef iAd
    [self initIadBannerView];
#endif
    [self initAdMobBannerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - AdBannerViewDelegate (iAd) Implementation
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
//    [TestFlight passCheckpoint:CHECKPOINT_AD_IAD_DISPLAYED];
    if (!self.adMobBannerView.hidden)
    {
        [self hideBanner:self.adMobBannerView];
    }
    [self showBanner:self.iAdBannerView];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (!self.iAdBannerView.hidden)
    {
        [self hideBanner:self.iAdBannerView];
    }
    // Fallback to AdMob Banner
    GADRequest *request = [GADRequest request];
    [self.adMobBannerView loadRequest:request];

}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    DLog(@"");
//    [TestFlight passCheckpoint:CHECKPOINT_AD_AD_CLICKED];
    [self stopActionsForAd];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    DLog(@"");
    [self hideBanner:banner];
    [self startActionsForAd];
}


#pragma mark - GADBannerViewDelegate (AdMob) Implementation
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    DLog(@"");
//    [TestFlight passCheckpoint:CHECKPOINT_AD_ADMOB_DISPLAYED];
    [self showBanner:bannerView];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error;
{
    DLog(@"");
    [self hideBanner:bannerView];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
//    [TestFlight passCheckpoint:CHECKPOINT_AD_AD_CLICKED];
    [self stopActionsForAd];
    [self hideBanner:bannerView];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    DLog(@"");
    self.view.frame = [self setFrame];
}

- (void)adViewWillDismissScreen:(GADBannerView *)bannerView
{
    DLog(@"");
    [self requestAdMob];
    [self startActionsForAd];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    DLog(@"");
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
        mIadBannerView.alpha = 0.0f;
        mIadBannerView.hidden = YES;
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
        mAdMobBannerView.rootViewController = self;
        mAdMobBannerView.delegate = self;
        mAdMobBannerView.alpha = 0.0f;
        mAdMobBannerView.hidden = YES;
        [self.view addSubview:mAdMobBannerView];
        [self willRequestAd];
    }
}

#pragma mark - Banner Animations
- (void)showBanner:(UIView *)banner
{
    if (banner &&
        [banner isHidden])
    {
        banner.hidden = NO;
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^ {
                             banner.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {

                         }];

    }
}

- (void)hideBanner:(UIView *)banner
{
    if (banner &&
        ![banner isHidden])
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^ {
                             banner.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             banner.hidden = YES;
                         }];
    }
}

- (CGRect)setFrame
{
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
    return viewFrame;
}

#pragma mark - Cocos2d Management
- (void) stopActionsForAd
{
	//Stop Director
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
}

- (void) startActionsForAd
{
//	[self rotateBannerView:[self currentOrientation]];
//	[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)[self currentOrientation]];
    
	//Resume Director
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];
}


#pragma mark - DEBUGGING METHODS
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
- (void)willRequestAd
{
#ifndef iAD
        [self requestAdMob];
        DLog(@"iAd Disabled - Requesting AdMob Banner");
#endif
}

- (void)requestAdMob
{
    // Only request adMob when iAd fails
    GADRequest *request = [GADRequest request];
#ifdef DEBUG
    request.testDevices = [NSArray arrayWithObjects:ADMOB_SIMULATOR_IDENTIFIER1,nil];
#endif
    LocationService *location = [LocationService sharedInstance];
    if (location.currentLocation != nil)
    {
        [request setLocationWithLatitude:location.currentLocation.coordinate.latitude
                               longitude:location.currentLocation.coordinate.longitude
                                accuracy:location.currentLocation.horizontalAccuracy];
    }
    [self.adMobBannerView loadRequest:request];
}

#pragma mark - Test
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    DLog(@"");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    DLog(@"");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    DLog(@"");
}
@end
