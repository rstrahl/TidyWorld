//
//  EditAlarmRepeatViewController_iPhone.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-25.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import "EditAlarmElementViewController.h"

@interface EditAlarmRepeatViewController : EditAlarmElementViewController
{
    NSUInteger _repeatBits;
}

@property (nonatomic, assign) NSUInteger repeatBits;

- (void)loadRepeatSchedule:(NSUInteger)repeatBits;

@end
