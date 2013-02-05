//
//  WorldOptionsViewController.h
//  TidyTime
//
//  Created by Rudi Strahl on 2012-10-09.
//
//

#import <UIKit/UIKit.h>
#import "SelectWeatherOptionViewController.h"

@interface WorldOptionsViewController : UITableViewController <SelectWeatherOptionDelegate>
{
    @private
    NSArray                             *mTableData;
    NSUserDefaults                      *mUserDefaults;
    id                                  __unsafe_unretained mDelegate;
    BOOL                                mOptionsChanged;
}

@property (nonatomic, strong) NSArray                               *tableData;
@property (nonatomic, strong) IBOutlet UIBarButtonItem              *doneButton;
@property (nonatomic, unsafe_unretained) id                         delegate;

/** Saves the changes to the world and dismisses itself */
- (IBAction)doneButtonPressed:(id)sender;

@end

/** This protocol must be adopted by any delegate intending to "listen" for changes to 
 the world. When the user interacts with the world options provided by WorldOptionsViewController
 any changes will result in the delegate being informed.
 */
@protocol WorldOptionsViewControllerDelegate <NSObject>
/** Notifies the delegate that the app will use location-based weather */
- (void)controller:(WorldOptionsViewController *)controller didChangeLocationBased:(BOOL)isLocationBased;
/** Notifies the delegate that the season has been changed */
- (void)controller:(WorldOptionsViewController *)controller didChangeSeason:(NSUInteger)season;
/** Notifies the delegate that the clouds state has been changed */
- (void)controller:(WorldOptionsViewController *)controller didChangeCloudsState:(NSUInteger)cloudState;
/** Notifies the delegate that the rain state has been changed */
- (void)controller:(WorldOptionsViewController *)controller didChangeRainState:(NSUInteger)rainState;
/** Notifies the delegate that the snow state has been changed */
- (void)controller:(WorldOptionsViewController *)controller didChangeSnowState:(NSUInteger)snowState;
/** Notifies the delegate that the fog state has been changed */
- (void)controller:(WorldOptionsViewController *)controller didChangeFogState:(NSUInteger)fogState;
/** Notifies the delegate that the lightning state has been changed */
- (void)controller:(WorldOptionsViewController *)controller didChangeLightningState:(NSUInteger)lightningState;
@end
