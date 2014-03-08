//
//  MainViewController.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-26.
//
//

#import <UIKit/UIKit.h>

@class ButtonTrayView;
@class ClockFaceView;

@interface MainViewController : UIViewController
{
    ButtonTrayView          *mButtonsView;
    ClockFaceView           *mClockView;
    UIScrollView            *mScrollView;
    id                      __unsafe_unretained mSceneDelegate;
    UIButton                *mLeftNavigationButton;
    UIButton                *mRightNavigationButton;
    NSTimer                 *mButtonsHighAlphaTimer;
    BOOL                    mAdsDisabled;
}

@property (nonatomic, strong) ButtonTrayView        *buttonsView;
@property (nonatomic, strong) ClockFaceView         *clockView;
@property (nonatomic, strong) UIButton              *leftNavigationButton;
@property (nonatomic, strong) UIButton              *rightNavigationButton;
@property (nonatomic, strong) NSTimer               *buttonsHighAlphaTimer;
@property (nonatomic, assign) BOOL adsDisabled;

- (void)setSceneDelegate:(id)sceneDelegate;

@end
