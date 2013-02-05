//
//  AlarmListViewController.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-14.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditAlarmViewController.h"

@class AlarmCellView;
@class AddItemRowTableView;
@class Alarm;

@interface AlarmListViewController : UIViewController
        <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, EditAlarmViewDelegate>
{
    @private
    AlarmCellView                       *mAlarmCell;
    NSManagedObjectContext              *mContext;
    NSFetchedResultsController          *mFetchedResultsController;
    NSDateFormatter                     *mDateFormatter;
    BOOL                                mUse24HourClock;
}

@property (nonatomic, strong) IBOutlet UITableView              *tableView;
@property (nonatomic, strong) IBOutlet AlarmCellView            *alarmCell;
@property (nonatomic, strong) IBOutlet UIBarButtonItem          *doneButton;
@property (nonatomic, strong) IBOutlet UIButton                 *addButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem          *editButton;
@property (nonatomic, strong) NSManagedObjectContext            *context;
@property (nonatomic, strong) NSFetchedResultsController        *fetchedResultsController;

- (IBAction)addButtonPressed:(id)sender;
- (IBAction)editButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)doneEditingButtonPressed:(id)sender;
- (IBAction)activeSwitchWasToggled:(id)sender;

/** Builds a string for the frequency label based on the alarm value */
+ (NSString *)buildFrequencyStringForAlarm:(Alarm *)alarm;

@end
