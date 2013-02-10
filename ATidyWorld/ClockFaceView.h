//
//  ClockFaceView.h
//  TidyTime
//
//  Created by Rudi Strahl on 12-06-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Alarm;

@interface ClockFaceView : UIView
{
    NSDateFormatter *mTimeFormatter;
    UIFont          *mFont;
    NSTimer         *mClockTempAnimationTimer;
    
    NSTimeInterval  mClockTime;
    float           mTemperature;
    NSString        *mLocation;
    
    BOOL            mUse24HourClock;
    BOOL            mUseCelsius;
    BOOL            mShowNextAlarm;
    BOOL            mShowDate;
    BOOL            mShowTemperature;
    BOOL            mClockIsTimeLapse;
}

@property (nonatomic, strong) IBOutlet UIView       *view;
@property (nonatomic, strong) IBOutlet UILabel      *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel      *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel      *ampmLabel;
@property (nonatomic, strong) IBOutlet UILabel      *temperatureLabel;
@property (nonatomic, strong) IBOutlet UILabel      *unitsLabel;
@property (nonatomic, strong) IBOutlet UILabel      *nextAlarmLabel;
@property (nonatomic, strong) IBOutlet UILabel      *locationLabel;
@property (nonatomic, strong) IBOutlet UIImageView  *alarmImageView;

/// Returns the current time used by the clock
- (NSTimeInterval)getClockTime;
/// Sets the current time for the clock
- (void)setClockTime:(NSTimeInterval)clockTime;
/// Returns the current temperature used by the clock
- (float)getTemperature;
/// Sets the current temperature for the clock
- (void)setTemperature:(float)temperature;
/// Returns the name of the location used by the clock
- (NSString *)getLocation;
/// Sets the name of the location used by the clock
- (void)setLocation:(NSString *)location;

@end
