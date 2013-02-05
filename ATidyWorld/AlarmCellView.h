//
//  AlarmCellView.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-14.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockConstants.h"

@interface AlarmCellView : UITableViewCell
{
}

@property (nonatomic, strong) IBOutlet UIImageView  *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIImageView  *problemIcon;
@property (nonatomic, strong) IBOutlet UILabel      *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel      *ampmLabel;
@property (nonatomic, strong) IBOutlet UILabel      *frequencyLabel;
@property (nonatomic, strong) IBOutlet UILabel      *titleLabel;
@property (nonatomic, strong) IBOutlet UISwitch     *enabledSwitch;

/** Applies a drop shadow behind all labels */
- (void)applyLabelDropShadow:(BOOL)applyDropShadow;

@end
