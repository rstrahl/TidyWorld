//
//  CoreLocationController.m
//  A Tidy World
//
//  Created by Rudi Strahl on 11-09-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationService.h"
#import "Constants.h"

static LocationService *sharedLocationController = nil;

@interface LocationService()

// Yahoo Geocoding Service
- (void)findWOEIDByLocation:(CLLocation *)location;

// Notifications
- (void)willSendLocationSuccessNotification;
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
            running = mRunning,
            internetReachable = mInternetReachable;

- (id)init
{
    if (self = [super init])
    {
        self.locationManager = [[CLLocationManager alloc] init]; // Create new instance of locMgr
        mLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager.delegate = self;
        const double testLatitude = 40.714224;
		const double testLongitude = -73.961452;
        
        mCurrentLocation = [[CLLocation alloc] initWithLatitude:testLatitude longitude:testLongitude];
        
        mWoeidServiceString = @"http://where.yahooapis.com/geocode";
        mWoeidServiceGFlags = @"R";
        mWoeidServiceFlags = @"J";
        mYahooApplicationID = @"rBibj342";
    }
    
    return self;
}

+ (id)sharedManager
{
    static dispatch_once_t safer;
    dispatch_once(&safer, ^{
        sharedLocationController = [[LocationService alloc] init];
        // private initialization goes here.
    });
    return sharedLocationController;
}

- (void)start
{
    if (self.internetReachable)
    {
        [mLocationManager startUpdatingLocation];
        mRunning = YES;
    }
    else
    {
        DLog(@"ERROR starting location service - internet not reachable");
        UIAlertView *noReachabilityAlertView =
        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_VIEW_NON_REACHABLE_TITLE", @"No Reachability")
                                   message:NSLocalizedString(@"ALERT_VIEW_NON_REACHABLE_MESSAGE", @"No Reachability")
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                         otherButtonTitles:nil];
        [noReachabilityAlertView show];
        [self willSendLocationFailedNotification];
    }
}

#pragma mark - CLLocationManagerDelegate Implementation
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{
//    DLog(@"");
    self.currentLocation = newLocation;
    [mLocationManager stopUpdatingLocation];
    mRunning = NO;
    
    // IOS5 Geocoding Code
    //[self geocodeLocation:newLocation];
    
    // Yahoo! Placefinder Geocoding code
    [self findWOEIDByLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	DLog(@"ERROR in CLLocationManager: %@", error);
    switch (error.code)
    {
        case kCLErrorDenied:
        {
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
            mRunning = NO;
            break;
        }
        default:
        {
            [self willSendLocationFailedNotification];
            [self.locationManager stopUpdatingLocation];
            mRunning = NO;
            break;
        }
    }
}

#pragma mark - Yahoo Geocoding Service
- (void)findWOEIDByLocation:(CLLocation *)location
{
    NSString *serviceURLString = [NSString stringWithFormat:@"%@?q=%f,+%f&gflags=%@&flags=%@&appid=%@",
                                  mWoeidServiceString, 
                                  location.coordinate.latitude, location.coordinate.longitude,
                                  mWoeidServiceGFlags,
                                  mWoeidServiceFlags,
                                  mYahooApplicationID];
    DLog(@"updateWithLocation URL: %@", serviceURLString);
    mWoeidServiceURL = [NSURL URLWithString:serviceURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:mWoeidServiceURL];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDelegate Implementation
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    mResponseData = [[NSMutableData alloc] init];
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
    NSString *responseString = [[NSString alloc] initWithData:mResponseData encoding:NSUTF8StringEncoding];
    DLog(@"Finished loading woeid response: \r %@", responseString);
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
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_UPDATE object:self];
}

- (void)willSendLocationFailedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_FAILED object:self];
}

@end
