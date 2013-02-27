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
}

@property (nonatomic, strong) ButtonTrayView *buttonsView;
@property (nonatomic, strong) ClockFaceView *clockView;
@property (nonatomic, assign) id sceneDelegate;


@end
