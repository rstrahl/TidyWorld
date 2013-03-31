//
//  AdsViewController.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-01-31.
//
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "GADBannerView.h"

/** Controller class for managing ad views and their delegate
 method calls.
 */
@interface AdsViewController : UIViewController <ADBannerViewDelegate, GADBannerViewDelegate>
{
    ADBannerView                        *mIadBannerView;    // iAd Banner View
    GADBannerView                       *mAdMobBannerView;  // Google AdMob Banner View
}

@property (nonatomic, strong) ADBannerView  *iAdBannerView;
@property (nonatomic, strong) GADBannerView *adMobBannerView;

/** Toggles the display of the banner Views, for debugging/layout purposes */
- (void)toggleAdMobBannerView;
- (void)toggleIadBannerView;

/** Signals the view controller to request an ad if needed */
- (void)willRequestAd;

@end
