//
//  SelectWeatherOptionViewController.h
//  TidyTime
//
//  Created by Rudi Strahl on 2012-10-15.
//
//

#import <UIKit/UIKit.h>
#import "WeatherService.h"

@protocol SelectWeatherOptionDelegate <NSObject>
/** Notifies the delegate of a change of value for a WeatherCategory */
- (void)willChangeValue:(NSInteger)value forCategory:(WeatherCategory)weatherCategory;
@end

@interface SelectWeatherOptionViewController : UITableViewController
{
    WeatherCategory                 mWeatherCategory;
    NSDictionary                    *mTableData;
    NSInteger                       mCheckedRow;
    NSIndexPath                     *mLastIndexPath;
    BOOL                            mOptionWasChanged;
    id<SelectWeatherOptionDelegate> __unsafe_unretained mWeatherOptionDelegate;
}

@property (nonatomic, strong) NSDictionary      *tableData;
@property (nonatomic, assign) WeatherCategory   weatherCategory;
@property (nonatomic, assign) NSInteger         checkedRow;
@property (nonatomic, assign) BOOL              optionWasChanged;
@property (nonatomic, strong) NSIndexPath       *lastIndexPath;
@property (nonatomic, unsafe_unretained) id<SelectWeatherOptionDelegate> weatherOptionDelegate;
@end

