//
//  EditAlarmViewController.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-15.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"
#import "EditAlarmElementViewController.h"

@class Alarm;
@class EditAlarmTitleViewController;
@class EditAlarmRepeatViewController;
@class EditAlarmSoundViewController;

@protocol EditAlarmViewDelegate <NSObject>

- (void)didReturnFromEditingAlarm:(Alarm *)alarm;
- (void)didCancelEditingAlarm;

@end

@interface EditAlarmViewController : UIViewController
    <EditAlarmElementViewDelegate>
{
    UITableView                                     *mTableView;
    UIDatePicker                                    *mTimePicker;
    UIBarButtonItem                                 *mSaveButton;
    UIBarButtonItem                                 *mCancelButton;
    UISwitch                                        *mSnoozeSwitch;
    
    Alarm                                           *mAlarm;
    id<EditAlarmViewDelegate> __unsafe_unretained   mDelegate;
    NSManagedObjectContext                          *mContext;
    BOOL                                            mIsNewAlarm;
    BOOL                                            mIsSaved;
}

@property (nonatomic, strong) IBOutlet UITableView                  *tableView;
@property (nonatomic, strong) IBOutlet UIDatePicker                 *timePicker;
@property (nonatomic, strong) IBOutlet UIBarButtonItem              *saveButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem              *cancelButton;
@property (nonatomic, strong) Alarm                                 *alarm;
@property (nonatomic, unsafe_unretained) id<EditAlarmViewDelegate>  delegate;
@property (nonatomic, strong) NSManagedObjectContext                *context;

- (id)initWithContext:(NSManagedObjectContext *)context;
- (id)initWithContext:(NSManagedObjectContext *)context forAlarm:(Alarm *)alarm;

// IBActions
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)snoozeSwitchToggled:(id)sender;

@end


