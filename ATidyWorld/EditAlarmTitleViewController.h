//
//  EditAlarmTitleViewController_iPhone.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-25.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditAlarmElementViewController.h"
#import "ClockConstants.h"

@interface EditAlarmTitleViewController : EditAlarmElementViewController
        <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    UITextField *_titleTextField;
    NSString *_alarmTitle;

}

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) NSString *alarmTitle;

@end


