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
    BOOL                                mLocationBasedWeather;
    WeatherCondition                    mCurrentWeatherCondition;
}

@property (nonatomic, strong) NSArray                               *tableData;
@property (nonatomic, strong) IBOutlet UIBarButtonItem              *doneButton;
@property (nonatomic, unsafe_unretained) id                         delegate;
@property (nonatomic, strong) IBOutlet UISwitch                     *lightningSwitch;

/** Saves the changes to the world and dismisses itself */
- (IBAction)doneButtonPressed:(id)sender;

@end

/** This protocol must be adopted by any delegate intending to "listen" for changes to 
 the world. When the user interacts with the world options provided by WorldOptionsViewController
 any changes will result in the delegate being informed.
 */
@protocol WorldOptionsViewControllerDelegate <NSObject>
/** Notifies the delegate that the weather conditions have changed 
 */
- (void)controller:(WorldOptionsViewController *)controller didChangeWeatherConditions:(WeatherCondition)condition;
/** Notifies the delegate that the app will use location-based weather 
 */
- (void)controller:(WorldOptionsViewController *)controller didChangeLocationBased:(BOOL)isLocationBased;
/** Notifies the delegate that the season has been changed 
 */
- (void)controller:(WorldOptionsViewController *)controller didChangeSeason:(NSUInteger)season;
@end
