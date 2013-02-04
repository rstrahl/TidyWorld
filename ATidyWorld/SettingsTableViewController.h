//
//  OptionsTableViewController.h
//  TidyTime
//
//  Created by Rudi Strahl on 2012-08-01.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
    OptionsSectionTime,
    OptionsSectionAlarm,
    OptionsSectionWeather,
    OptionsSectionGeneral
} OptionsSection;

@interface SettingsTableViewController : UITableViewController
{
    NSUserDefaults                      *mUserDefaults;
    NSArray                             *mOptionsTableData;
    NSArray                             *mOptionsTableSectionHeaders;
    NSMutableArray                      *mTimeOptionsData;
    NSArray                             *mAlarmOptionsData;
    NSArray                             *mWeatherOptionsData;
    NSArray                             *mDisplayOptionsData;
    NSArray                             *mGeneralOptionsData;
    BOOL                                mSettingsChanged;
}

// IBActions
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)switchToggled:(id)sender;
- (IBAction)segmentSelected:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;

@end
