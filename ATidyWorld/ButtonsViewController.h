//
//  ButtonsViewController.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-03.
//
//

#import <UIKit/UIKit.h>

/** View Controller that manages the buttons for changing the state of the app or its contents. 
 Acts as delegate for any modal view controllers.  Should be considered the root (and "only") 
 view controller in the app.
 */
@interface ButtonsViewController : UIViewController
{
    id                  __unsafe_unretained mDelegate; // Intended to be a reference back to the Scene object
    UIButton            *mAlarmClockButton;
    UIButton            *mChangeSeasonButton;
    UIButton            *mChangeWorldButton;
    UIButton            *mSettingsButton;
}

@property (nonatomic, assign) id delegate;

- (IBAction)alarmClockButtonPressed:(id)sender;
- (IBAction)changeSeasonButtonPressed:(id)sender;
- (IBAction)changeWorldButtonPressed:(id)sender;
- (IBAction)settingsButtonPressed:(id)sender;

@end
