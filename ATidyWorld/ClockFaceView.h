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
    BOOL            mSyncWithRealTime;
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

- (NSTimeInterval)getClockTime;
- (void)setClockTime:(NSTimeInterval)clockTime;
- (float)getTemperature;
- (void)setTemperature:(float)temperature;
- (NSString *)getLocation;
- (void)setLocation:(NSString *)location;

- (void)updateClockFace:(NSTimeInterval)time;
- (void)updateDateForTimeInterval:(NSTimeInterval)time;
- (void)updateTemperature:(float)temperature;
- (void)updateLocation:(NSString *)location;
- (void)updateUIForSettings;
- (void)updateNextAlarm:(Alarm *)alarm;
- (void)swapTimeTemperatureAnimation;

@end
