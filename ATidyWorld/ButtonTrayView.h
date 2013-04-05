//
//  ButtonsViewController.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-03.
//
//

#import <UIKit/UIKit.h>

/** View Controller that manages the buttons for changing the state of the app or its contents. 
 *  Acts as delegate for any modal view controllers.  Should be considered the root (and "only")
 *  view controller in the app.
 */
@interface ButtonTrayView : UIView
{
    @private
    id                  __unsafe_unretained mSceneDelegate; //< Intended to be a reference back to the Scene object
    UIButton            *mAlarmClockButton;
    UIButton            *mChangeWorldButton;
    UIButton            *mSettingsButton;
    UIViewController    *mParentViewController;
}

@property (nonatomic, assign) id                    sceneDelegate;
@property (nonatomic, strong) UIViewController      *parentViewController;
@property (nonatomic, strong) UIPopoverController   *popoverController;

- (IBAction)alarmClockButtonPressed:(id)sender;
- (IBAction)changeWorldButtonPressed:(id)sender;
- (IBAction)settingsButtonPressed:(id)sender;

@end
