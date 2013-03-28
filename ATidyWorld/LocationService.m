//
//  CoreLocationController.m
//  A Tidy World
//
//  Created by Rudi Strahl on 11-09-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationService.h"
#import "Constants.h"
#import "Reachability.h"

static LocationService *sharedLocationController = nil;

@interface LocationService()

/// Determine location identifier for Yahoo! Weather Service
- (void)findWOEIDByLocation:(CLLocation *)location;
/// Send notification that a location was successfully determined
- (void)willSendLocationSuccessNotification;
/// Send notification that a location failed to be determined
- (void)willSendLocationFailedNotification;

@end

@implementation LocationService

@synthesize locationManager = mLocationManager,
            currentLocation = mCurrentLocation,
            delegate = mDelegate,
            woeid = mWoeid,
            city = mCity,
            state = mState,
            country = mCountry,
            serviceTimer = mServiceTimer,
            running = mRunning,
            internetReachable = mInternetReachable,
            locationErrorCode = mLocationErrorCode;

- (id)init
{
    if (self = [super init])
    {
        self.running = YES;
        mLocationManager = [[CLLocationManager alloc] init]; // Create new instance of locMgr
        mLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager.delegate = self;
//        const double testLatitude = 40.714224;
//		const double testLongitude = -73.961452;
//        
//        mCurrentLocation = [[CLLocation alloc] initWithLatitude:testLatitude longitude:testLongitude];
        
        mWoeidServiceString = @"http://where.yahooapis.com/geocode";
        mWoeidServiceGFlags = @"R";
        mWoeidServiceFlags = @"J";
        mYahooApplicationID = @"rBibj342";
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveReachabilityNotification:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    }
    
    return self;
}

+ (id)sharedInstance
{
    static dispatch_once_t safer;
    dispatch_once(&safer, ^{
        sharedLocationController = [[LocationService alloc] init];
        // private initialization goes here.
    });
    return sharedLocationController;
}

- (void)startLocationAttempt
{
    if (self.internetReachable)
    {
        if (self.isRunning)
        {
            [mLocationManager startUpdatingLocation];
        }
    }
    else
    {
        self.running = NO;
        UIAlertView *noReachabilityAlertView =
        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_VIEW_NON_REACHABLE_TITLE", @"No Reachability")
                                   message:NSLocalizedString(@"ALERT_VIEW_NON_REACHABLE_MESSAGE", @"No Reachability")
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                         otherButtonTitles:nil];
        [noReachabilityAlertView show];
        self.locationErrorCode = kLocationServiceNotReachable;
        [self willSendLocationFailedNotification];
    }
}

#pragma mark - CLLocationManagerDelegate Implementation
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{
    self.currentLocation = newLocation;
    mLocationErrorCode = -1;
    [mLocationManager stopUpdatingLocation];
    
    // IOS5 Geocoding Code
    //[self geocodeLocation:newLocation];
    
    // Yahoo! Placefinder Geocoding code
    [self findWOEIDByLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	DLog(@"ERROR in CLLocationManager: %@", error);
    mLocationErrorCode = error.code;
    switch (mLocationErrorCode)
    {
        case kCLErrorDenied:
        {
            self.running = NO;
            DLog(@"No location services authorized");
            UIAlertView *noLocationAlertView =
            [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_VIEW_LOCATION_DISABLED_TITLE", @"Location Disabled")
                                       message:NSLocalizedString(@"ALERT_VIEW_LOCATION_DISABLED_MESSAGE", @"Location Disabled")
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                             otherButtonTitles:nil];
            [noLocationAlertView show];
            [self willSendLocationFailedNotification];
            [self.locationManager stopUpdatingLocation];
            break;
        }
        case kCLErrorLocationUnknown:
        {
            [self willSendLocationFailedNotification];
            break;
        }
        default:
        {
            [self willSendLocationFailedNotification];
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

#pragma mark - Yahoo Geocoding Service
- (void)findWOEIDByLocation:(CLLocation *)location
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if ((now - mLastLocationUpdateTime) > 120 || mCurrentLocation == nil)
    {
        mLastLocationUpdateTime = now;
        NSString *serviceURLString = [NSString stringWithFormat:@"%@?q=%f,+%f&gflags=%@&flags=%@&appid=%@",
                                      mWoeidServiceString,
                                      location.coordinate.latitude, location.coordinate.longitude,
                                      mWoeidServiceGFlags,
                                      mWoeidServiceFlags,
                                      mYahooApplicationID];
//        DLog(@"updateWithLocation URL: %@", serviceURLString);
        mWoeidServiceURL = [NSURL URLWithString:serviceURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:mWoeidServiceURL];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection)
        {
            mResponseData = [[NSMutableData alloc] init];
        }
        else
        {
            DLog(@"ERROR initializing connection for location service");
            UIAlertView *noReachabilityAlertView =
            [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_VIEW_WEATHER_PROBLEM_TITLE", @"No Reachability")
                                       message:NSLocalizedString(@"ALERT_VIEW_WEATHER_PROBLEM_MESSAGE", @"No Reachability")
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                             otherButtonTitles:nil];
            [noReachabilityAlertView show];
            self.locationErrorCode = kLocationServiceNotReachable;
            [self willSendLocationFailedNotification];
        }

    }
    else
    {
        DLog(@"IGNORING repeat call to locationDidUpdate within 2 minutes");
    }
}

#pragma mark - NSURLConnectionDelegate Implementation
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[mResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	DLog(@"ERROR connection failed: %@", [error description]);
    [self willSendLocationFailedNotification];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    NSString *responseString = [[NSString alloc] initWithData:mResponseData encoding:NSUTF8StringEncoding];
//    DLog(@"Finished loading woeid response: \r %@", responseString);
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:mResponseData options:kNilOptions error:&error];
    
    NSDictionary *results = [(NSArray *)[(NSDictionary *)[jsonData objectForKey:@"ResultSet"] objectForKey:@"Results"] objectAtIndex:0];
    
    self.woeid = [NSNumber numberWithInt:[[results objectForKey:@"woeid"] intValue]];
    self.city = [results objectForKey:@"city"];
    self.state = [results objectForKey:@"state"];
    self.country = [results objectForKey:@"country"];
        
    [self willSendLocationSuccessNotification];
}

#pragma mark - Notifications
- (void)willSendLocationSuccessNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_SUCCESS object:self];
}

- (void)willSendLocationFailedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_FAILED object:self];
}

- (void)willSendLocationUnchangedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_UNCHANGED object:self];
}

#pragma mark - Notification Listeners
- (void)didReceiveReachabilityNotification:(NSNotification *)notification
{
    Reachability *reachable = (Reachability *)notification.object;
    self.internetReachable = reachable.isReachable;
}

#pragma mark - Service Timer Control
- (void)startServiceTimer
{
    if (self.serviceTimer == nil)
    {
        DLog(@"Creating and starting service timer");
        self.serviceTimer = [NSTimer timerWithTimeInterval:900
                                                    target:[LocationService sharedInstance]
                                                  selector:@selector(startLocationAttempt)
                                                  userInfo:nil
                                                   repeats:YES];
        [self startLocationAttempt];
    }
}

- (void)stopServiceTimer
{
    if (self.serviceTimer != nil)
    {
        if (self.serviceTimer.isValid)
        {
            DLog(@"Invalidating service timer...");
            [self.serviceTimer invalidate];
        }
        DLog(@"Service timer being nil'd...");
        self.serviceTimer = nil;
    }
}

@end
