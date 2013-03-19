//
//  DebuggingViewController.h
//  A Tidy World
//
//  Created by Rudi Strahl on 11-09-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DebugDataViewController : UIViewController 
{
    UILabel *latitudeLabel;
    UILabel *longitudeLabel;
    UILabel *timeLabel;
    UILabel *alarmLabel;
    UILabel *locationLabel;
    UILabel *timezoneLabel;
    UILabel *conditionTextLabel;
    UILabel *conditionTempLabel;
    UILabel *conditionCodeLabel;
    UILabel *astronomySunriseLabel;
    UILabel *astronomySunsetLabel;
    UILabel *windChillLabel;
    UILabel *windDirectionLabel;
    UILabel *windSpeedLabel;
    UILabel *atmosphereHumidityLabel;
    UILabel *atmospherePressureLabel;
    UILabel *atmosphereRisingLabel;
    UILabel *atmosphereVisibilityLabel;
    
    NSDateFormatter *timeFormatter;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, strong) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *alarmLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UILabel *timezoneLabel;
@property (nonatomic, strong) IBOutlet UILabel *conditionTextLabel;
@property (nonatomic, strong) IBOutlet UILabel *conditionTempLabel;
@property (nonatomic, strong) IBOutlet UILabel *conditionCodeLabel;
@property (nonatomic, strong) IBOutlet UILabel *astronomySunriseLabel;
@property (nonatomic, strong) IBOutlet UILabel *astronomySunsetLabel;
@property (nonatomic, strong) IBOutlet UILabel *windChillLabel;
@property (nonatomic, strong) IBOutlet UILabel *windDirectionLabel;
@property (nonatomic, strong) IBOutlet UILabel *windSpeedLabel;
@property (nonatomic, strong) IBOutlet UILabel *atmosphereHumidityLabel;
@property (nonatomic, strong) IBOutlet UILabel *atmospherePressureLabel;
@property (nonatomic, strong) IBOutlet UILabel *atmosphereRisingLabel;
@property (nonatomic, strong) IBOutlet UILabel *atmosphereVisibilityLabel;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (void)didReceiveLocationUpdateNotification:(NSNotification *)notification;
- (void)didReceiveWeatherSuccessNotification:(NSNotification *)notification;

@end
