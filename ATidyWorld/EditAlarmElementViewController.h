//
//  EditAlarmElementViewController.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-25.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditAlarmElementViewDelegate <NSObject>

- (void)didReturnFromEditingAlarmElement:(NSString *)key withValue:(NSObject *)value;

@end

@interface EditAlarmElementViewController : UIViewController
{
    UITableView *_tableView;
    id<EditAlarmElementViewDelegate> __unsafe_unretained _delegate;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, unsafe_unretained) id<EditAlarmElementViewDelegate> delegate;

@end

