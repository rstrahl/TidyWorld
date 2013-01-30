//
//  ClockFaceView.m
//  TidyTime
//
//  Created by Rudi Strahl on 12-06-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ClockFaceView.h"
#import "ClockConstants.h"
#import "SettingsConstants.h"
// TODO: DEPRECATED: Remove if no longer using the next-alarm feature
//#import "Alarm.h"
//#import "CoreLocationController.h"
#import "Constants.h"

@interface ClockFaceView()

@end

@implementation ClockFaceView

@synthesize timeLabel,
            dateLabel,
            ampmLabel,
            temperatureLabel,
            unitsLabel,
            nextAlarmLabel,
            alarmImageView,
            locationLabel,
            view;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"ClockFaceView" owner:self options:nil];
        self.timeLabel.text = @"";
        self.timeLabel.font = [UIFont fontWithName:@"CenturyGothic" size:64];
        self.dateLabel.text = @"";
        self.dateLabel.font = [UIFont fontWithName:@"CenturyGothic" size:16];
        self.ampmLabel.text = @"";
        self.ampmLabel.font = [UIFont fontWithName:@"CenturyGothic" size:22];
        self.temperatureLabel.text = @"";
        self.temperatureLabel.font = [UIFont fontWithName:@"CenturyGothic" size:64];
        self.temperatureLabel.alpha = 0;
        self.unitsLabel.text = @"";
        self.unitsLabel.font = [UIFont fontWithName:@"CenturyGothic" size:22];
        self.unitsLabel.alpha = 0;
        self.locationLabel.text = @"";
        self.locationLabel.font = [UIFont fontWithName:@"CenturyGothic" size:16];
        self.locationLabel.alpha = 0;
//        self.alarmImageView.hidden = YES;
//        self.nextAlarmLabel.text = @"";
//        self.nextAlarmLabel.font = [UIFont fontWithName:@"CenturyGothic" size:14];
        [self updateUIForSettings];
        [self addSubview:self.view];
    }
    return self;
}

#pragma mark - Getters/Setters
- (NSTimeInterval)getClockTime
{
    return mClockTime;
}

- (void)setClockTime:(NSTimeInterval)clockTime
{
    mClockTime = clockTime;
    [self updateClockFace:mClockTime];
}

- (float)getTemperature
{
    return mTemperature;
}

- (void)setTemperature:(float)temperature
{
    mTemperature = temperature;
    [self updateTemperature:mTemperature];
}

- (NSString *)getLocation
{
    return mLocation;
}

- (void)setLocation:(NSString *)location
{
    mLocation = location;
    [self updateLocation:mLocation];
}


#pragma mark - UI Updates
- (void)updateClockFace:(NSTimeInterval)time
{
    // TODO: CODE REVIEW: Determine if required and delete if obsolete
//    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
//    NSString *timeString = [mTimeFormatter stringFromDate:date];
//    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@",
//                           [[timeString componentsSeparatedByString:@":"] objectAtIndex:4],
//                           [[timeString componentsSeparatedByString:@":"] objectAtIndex:5] ];
//    if (!mUse24HourClock)
//    {
//        NSString *ampmString =  (NSString *)[[timeString componentsSeparatedByString:@":"] objectAtIndex:6];
//        if([ampmString isEqualToString:@"PM"]){
//            [ampmLabel setText:NSLocalizedString(@"PM", @"PM")];
//        }
//        else
//        {
//            [ampmLabel setText:NSLocalizedString(@"AM", @"AM")];
//        }
//        [self.ampmLabel setHidden:NO];
//    }
//    else
//    {
//        [self.ampmLabel setHidden:YES];
//    }
    // TIME Label
    time += [[NSTimeZone localTimeZone] secondsFromGMT];
    int hours = time / 3600;
    int minutes = ((int)time % 3600) / 60;
    
    if (!mUse24HourClock)
    {
        if ((hours / 12) == 1)
            [ampmLabel setText:NSLocalizedString(@"PM", @"PM")];
        else
            [ampmLabel setText:NSLocalizedString(@"AM", @"AM")];
        
        hours %= 12;
        
        if (hours == 0)
            hours = 12;
        timeLabel.text = [NSString stringWithFormat:@"%d:%.2d", hours, minutes];
    }
    else
    {
        timeLabel.text = [NSString stringWithFormat:@"%.2d:%.2d", hours, minutes];
        [ampmLabel setHidden:YES];
    }

    // Arrange Time Label
    CGSize expectedTimeLabelSize = [timeLabel.text sizeWithFont:timeLabel.font
                                                       forWidth:200
                                                  lineBreakMode:timeLabel.lineBreakMode];
    CGRect timeLabelFrame = CGRectMake((self.frame.size.width / 2) - (expectedTimeLabelSize.width / 2) - (self.ampmLabel.frame.size.width / 2),
                                        self.frame.origin.y,
                                        expectedTimeLabelSize.width,
                                        self.timeLabel.frame.size.height);
    if (mUse24HourClock)
    {
        timeLabelFrame.origin.x += (self.ampmLabel.frame.size.width / 2);
    }
    [self.timeLabel setFrame:timeLabelFrame];
    
    // Arrange am/pm Label
    CGRect ampmRect = CGRectMake((timeLabel.frame.origin.x + expectedTimeLabelSize.width),
                                 (timeLabel.frame.size.height - ampmLabel.frame.size.height),
                                 ampmLabel.frame.size.width, 
                                 ampmLabel.frame.size.height);
    [self.ampmLabel setFrame:ampmRect];
    
}

- (void)updateDateForTimeInterval:(NSTimeInterval)time
{
    // Arrange Date Label
    if (mShowDate)
    {
        if (!mSyncWithRealTime)
        {
            self.dateLabel.text = NSLocalizedString(@"SOMEDAY", @"Someday");
        }
        else
        {
            NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
            NSString *timeString = [mTimeFormatter stringFromDate:date];
            self.dateLabel.text = [NSString stringWithFormat:@"%@, %@ %@ %@",
                                   [[timeString componentsSeparatedByString:@":"] objectAtIndex:0],
                                   [[timeString componentsSeparatedByString:@":"] objectAtIndex:1],
                                   [[timeString componentsSeparatedByString:@":"] objectAtIndex:2],
                                   [[timeString componentsSeparatedByString:@":"] objectAtIndex:3] ];
        }
        
        CGSize expectedDateLabelSize = [dateLabel.text sizeWithFont:dateLabel.font
                                                  constrainedToSize:CGSizeMake(260, 24)
                                                      lineBreakMode:dateLabel.lineBreakMode];
        CGRect dateLabelFrame = CGRectMake((self.frame.size.width / 2) - (expectedDateLabelSize.width / 2),
                                           self.timeLabel.frame.origin.y + self.timeLabel.frame.size.height,
                                           expectedDateLabelSize.width,
                                           dateLabel.frame.size.height);
        [self.dateLabel setFrame:dateLabelFrame];
    }
}

- (void)updateTemperature:(float)temperature
{
    if (mShowTemperature)
    {
        float temp = temperature;
        if (mUseCelsius)
        {
            temp = (temp - 32) * 5/9;
            self.unitsLabel.text = NSLocalizedString(@"CELSIUS", @"Celsius Abbrevation");
        }
        else
        {
            self.unitsLabel.text = NSLocalizedString(@"FAHRENHEIT", @"Fahrenheit Abbrevation");
        }
        self.temperatureLabel.text = [NSString stringWithFormat:@"%0.0f", temp];
        
        // Arrange Temp Label
        CGSize expectedTempLabelSize = [self.temperatureLabel.text sizeWithFont:temperatureLabel.font
                                                           forWidth:100
                                                      lineBreakMode:timeLabel.lineBreakMode];
        CGRect tempLabelFrame = CGRectMake((self.frame.size.width / 2) - (expectedTempLabelSize.width / 2),
                                           self.frame.origin.y,
                                           expectedTempLabelSize.width,
                                           self.temperatureLabel.frame.size.height);
        [self.temperatureLabel setFrame:tempLabelFrame];
        
        // Arrange Units Label
        // Arrange am/pm Label
        CGRect unitsFrame = CGRectMake((self.temperatureLabel.frame.origin.x + expectedTempLabelSize.width),
                                     (self.temperatureLabel.frame.size.height - self.unitsLabel.frame.size.height),
                                     self.unitsLabel.frame.size.width,
                                     self.unitsLabel.frame.size.height);
        [self.unitsLabel setFrame:unitsFrame];
    }
}

- (void)updateLocation:(NSString *)location
{
    CGSize expectedLabelSize = [location sizeWithFont:self.locationLabel.font
                                    constrainedToSize:CGSizeMake(300, 24)
                                        lineBreakMode:locationLabel.lineBreakMode];
    CGRect locationLabelFrame = CGRectMake((self.frame.size.width / 2) - (expectedLabelSize.width / 2),
                                           self.temperatureLabel.frame.origin.y + self.temperatureLabel.frame.size.height,
                                           expectedLabelSize.width,
                                           self.locationLabel.frame.size.height);
    [self.locationLabel setFrame:locationLabelFrame];
    self.locationLabel.text = location;
}

- (void)updateUIForSettings
{
    mTimeFormatter = [[NSDateFormatter alloc] init];
    [mTimeFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [mTimeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Temperature Settings
    mUseCelsius = [defaults boolForKey:SETTINGS_KEY_USE_CELSIUS];
    mShowTemperature = [defaults boolForKey:SETTINGS_KEY_SHOW_TEMP];
//    [self updateTemperature:[[[WeatherService sharedWeatherService] conditionTemp] floatValue]];
    self.temperatureLabel.hidden = !mShowTemperature;
    self.unitsLabel.hidden = !mShowTemperature;
    
    // Time Settings
    mShowDate = [defaults boolForKey:SETTINGS_KEY_SHOW_DATE];
    self.dateLabel.hidden = !mShowDate;
    
    mSyncWithRealTime = [defaults boolForKey:SETTINGS_KEY_SYNC_CLOCK_TO_REAL_WORLD];    
    mUse24HourClock = [defaults boolForKey:SETTINGS_KEY_USE_24_HOUR_CLOCK];
    if (!mUse24HourClock)
    {
        [mTimeFormatter setDateFormat:@"EEEE:MMMM:dd:yyyy:h:mm:a"];
    }
    else
    {
        [mTimeFormatter setDateFormat:@"EEEE:MMMM:dd:yyyy:H:mm"];
    }
    
    // Start the timer for animating the swap between time and temp
    if (mShowTemperature)
    {
        if (mClockTempAnimationTimer == nil)
        {
            DLog(@"Starting Time/Temp animation timer");
            mClockTempAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                                target:self
                                                              selector:@selector(swapTimeTemperatureAnimation)
                                                              userInfo:nil
                                                               repeats:YES];
        }
    }
    else
    {
        if (mClockTempAnimationTimer != nil)
        {
            DLog(@"Stopping Time/Temp animation timer");
            if (mClockTempAnimationTimer.isValid)
            {
                [mClockTempAnimationTimer invalidate];
            }
            mClockTempAnimationTimer = nil;
            self.timeLabel.alpha = 1.0f;
            self.ampmLabel.alpha = 1.0f;
            self.dateLabel.alpha = 1.0f;
            self.temperatureLabel.alpha = 0.0f;
            self.unitsLabel.alpha = 0.0f;
            self.locationLabel.alpha = 0.0f;
        }
    }
}

// TODO: DEPRECATED: Consider removing if next-alarm function is never requested
//- (void)updateNextAlarm:(Alarm *)alarm
//{
//    if (mShowNextAlarm)
//    {
//        if (alarm != nil)
//        {
//            NSString *timeString = nil;
//            self.alarmImageView.hidden = NO;
//            [self.alarmImageView setImage:[UIImage imageNamed:@"Icon_Alarm.png"]];
//            int hours = [alarm.time doubleValue] / 3600;
//            int minutes = ([alarm.time intValue] % 3600) / 60;
//            
//            if (!mUse24HourClock)
//            {
//                if (hours > 12)
//                {
//                    hours = hours - 12;
//                    timeString = [NSString stringWithFormat:@"%d:%.2d %@", hours, minutes, NSLocalizedString(@"PM", @"PM")];
//                }
//                else
//                {
//                    if (hours == 0)
//                        hours = 12;
//                    timeString = [NSString stringWithFormat:@"%d:%.2d %@", hours, minutes, NSLocalizedString(@"AM", @"AM")];
//                }
//                
//            }
//            else
//            {
//                timeString = [NSString stringWithFormat:@"%d:%.2d", hours, minutes];
//            }
//            self.nextAlarmLabel.text = [NSString stringWithFormat:@"%@ - %@", timeString, alarm.title];
//        }
//        else
//        {
//            [self.alarmImageView setImage:nil];
//            self.alarmImageView.hidden = YES;
//            self.nextAlarmLabel.text = @"";
//        }
//    }
//}

- (void)swapTimeTemperatureAnimation
{
    if (self.temperatureLabel.alpha == 1)
    {
        // Fade out temp and fade in clock
        [UIView animateWithDuration:1
                         animations:^{
                             self.temperatureLabel.alpha = 0.0;
                             self.unitsLabel.alpha = 0.0f;
                             self.locationLabel.alpha = 0.0f;
	                     }
         
                         completion:^(BOOL  completed){
                             [UIView animateWithDuration:1
                                              animations:^{
                                                  self.timeLabel.alpha = 1.0;
                                                  self.ampmLabel.alpha = 1.0f;
                                                  self.dateLabel.alpha = 1.0f;
                                              }
                              
                                              completion:^(BOOL  completed){
                                              }
                              ];
                         }
         ];
    }
    else if (self.timeLabel.alpha == 1)
    {
        // Fade out clock and fade in temp
        [UIView animateWithDuration:1
                         animations:^{
                             self.timeLabel.alpha = 0.0;
                             self.ampmLabel.alpha = 0.0f;
                             self.dateLabel.alpha = 0.0f;
	                     }
         
                         completion:^(BOOL  completed){
                             [UIView animateWithDuration:1
                                              animations:^{
                                                  self.temperatureLabel.alpha = 1.0;
                                                  self.unitsLabel.alpha = 1.0f;
                                                  self.locationLabel.alpha = 1.0f;
                                              }
                              
                                              completion:^(BOOL  completed){
                                              }
                              ];
                         }
         ];
    }
}


@end
