//
//  DebuggingViewController.m
//  A Tidy World
//
//  Created by Rudi Strahl on 11-09-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DebugDataViewController.h"
#import "AppDelegate.h"
#import "LocationService.h"
#import "WeatherService.h"
#import "Constants.h"
#import "SettingsConstants.h"

@implementation DebugDataViewController

@synthesize latitudeLabel,
            longitudeLabel,
            timeLabel,
            alarmLabel,
            locationLabel,
            timezoneLabel,
            conditionCodeLabel,
            conditionTempLabel,
            conditionTextLabel,
            astronomySunriseLabel,
            astronomySunsetLabel,
            windChillLabel,
            windDirectionLabel,
            windSpeedLabel,
            atmosphereHumidityLabel,
            atmospherePressureLabel,
            atmosphereRisingLabel,
            atmosphereVisibilityLabel,
            lastUpdatedLabel,
            timeFormatter,
            dateFormatter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = NSLocalizedString(@"VIEW_TITLE_DEBUG_DATA", nil);

        // TODO: Add locale detection
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE MMMM d"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveWeatherSuccessNotification:)
                                                     name:NOTIFICATION_WEATHER_SUCCESS
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveLocationUpdateNotification:) 
                                                     name:NOTIFICATION_LOCATION_SUCCESS
                                                   object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUIWithWeather:[WeatherService sharedInstance]];
    [self updateUIWithLocation:[LocationService sharedInstance]];
    self.contentSizeForViewInPopover = CGSizeMake(320,436);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    timeFormatter = [[NSDateFormatter alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL use24HourClock = [defaults boolForKey:SETTINGS_KEY_USE_24_HOUR_CLOCK];
    if (!use24HourClock)
    {
        [timeFormatter setDateFormat:@"K:mm:ss a"];
    } 
    else
    {
        [timeFormatter setDateFormat:@"HH:mm:ss"];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)updateUIWithWeather:(WeatherService *)service
{
    self.conditionCodeLabel.text = [NSString stringWithFormat:@"%@", service.conditionCode];
    self.conditionTempLabel.text = [NSString stringWithFormat:@"%@ 'F", service.conditionTemp];
    self.conditionTextLabel.text = service.conditionText;
    self.astronomySunriseLabel.text = service.astronomySunrise;
    self.astronomySunsetLabel.text = service.astronomySunset;
    self.windChillLabel.text = service.windChill;
    self.windDirectionLabel.text = service.windDirection;
    self.windSpeedLabel.text = service.windSpeed;
    self.atmosphereHumidityLabel.text = [NSString stringWithFormat:@"%@", service.atmosphereHumidity];
    self.atmospherePressureLabel.text = [NSString stringWithFormat:@"%@", service.atmospherePressure];
    self.atmosphereRisingLabel.text = [NSString stringWithFormat:@"%@", service.atmosphereRising];
    self.atmosphereVisibilityLabel.text = [NSString stringWithFormat:@"%@", service.atmosphereVisibility];
    self.lastUpdatedLabel.text = [NSString stringWithFormat:@"%@", service.lastUpdateTime];
}

- (void)updateUIWithLocation:(LocationService *)service
{
    self.timezoneLabel.text = [NSString stringWithFormat:@"%@", [NSTimeZone localTimeZone]];
    DLog(@"%@", [NSTimeZone localTimeZone]);
    NSString *locationString = [NSString stringWithFormat:@"%@, %@, %@", service.city, service.state, service.country];
    self.locationLabel.text = locationString; 
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f", service.currentLocation.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%f", service.currentLocation.coordinate.longitude];
}

#pragma mark - Location Service Notification
- (void)didReceiveLocationUpdateNotification:(NSNotification *)notification
{
    [self updateUIWithLocation:[LocationService sharedInstance]];
}

#pragma mark - Weather Service Notification
- (void)didReceiveWeatherSuccessNotification:(NSNotification *)notification
{
    [self updateUIWithWeather:[WeatherService sharedInstance]];
}

@end