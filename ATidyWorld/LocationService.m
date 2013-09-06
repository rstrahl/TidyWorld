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
#import "TMOSVersionDetection.h"

static LocationService *sharedLocationController = nil;

@interface LocationService()
- (void)geocodeIOS4Location:(CLLocation*)location;
- (void)geocodeIOS5Location:(CLLocation*)location;
/// Determine location identifier for Yahoo! Weather Service DEPRECATED	
- (void)findWOEIDByLocation:(CLLocation *)location;
/// Determine location identifier for Yahoo! Weather Service
- (void)findWOEIDByAddressString:(NSString *)address;
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
            locationErrorCode = mLocationErrorCode,
            locationUpdateCount = mLocationUpdateCount;

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
        
//        mWoeidServiceString = @"http://where.yahooapis.com/geocode"; // NO LONGER VALID AS OF APRIL 2013! >:(
        mWoeidServiceString = @"http://gws2.maps.yahoo.com/findlocation";
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
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if ((now - mLastLocationUpdateTime) > 15 || mCurrentLocation == nil)
    {
        mLastLocationUpdateTime = now;
        self.currentLocation = newLocation;
        mLocationErrorCode = -1;
        [mLocationManager stopUpdatingLocation];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        {
            // IOS5 Geocoding Code
            [self geocodeIOS5Location:newLocation];
        }
        else
        {
            // IOS4.x Geocoding Code
            [self geocodeIOS4Location:newLocation];
        }
    }
    else
    {
        DLog(@"Ignoring location request newer than 15 seconds");
    }
    // Yahoo! Placefinder Geocoding code
//    [self findWOEIDByLocation:newLocation];
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

#pragma mark - iOS 4.1 Geocoding
- (void)geocodeIOS4Location:(CLLocation*)location
{
    MKReverseGeocoder* theGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
    
    theGeocoder.delegate = self;
    [theGeocoder start];
}

- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFindPlacemark:(MKPlacemark*)place
{
    NSString *address = [NSString stringWithFormat:@"%@,%@,%@",
                         place.locality,
                         place.administrativeArea,
                         place.country];
    
    self.city = place.locality;
    self.state = place.administrativeArea;
    self.country = place.country;
    [self findWOEIDByAddressString:address];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    UIAlertView *noLocationAlertView =
    [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_VIEW_LOCATION_ERROR_TITLE", @"Location Failed")
                               message:NSLocalizedString(@"ALERT_VIEW_LOCATION_ERROR_MESSAGE", @"Location Failed")
                              delegate:nil
                     cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                     otherButtonTitles:nil];
    [noLocationAlertView show];
    [self willSendLocationFailedNotification];
    [self analyticsLogGeocodingException:[NSString stringWithFormat:@"ERROR geocoding location: %@", [error description]]];
}

#pragma mark - iOS 5+ Geocoding
- (void)geocodeIOS5Location:(CLLocation*)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if (!error)
        {
            //Get nearby address
            CLPlacemark *place = [placemarks objectAtIndex:0];
            NSString *address = [NSString stringWithFormat:@"%@,%@,%@",
                                 place.locality,
                                 place.administrativeArea,
                                 place.country];
            self.city = (place.locality == nil) ? @"?" : place.locality;
            self.state = (place.administrativeArea == nil) ? @"?" : place.administrativeArea;
            self.country = (place.country == nil) ? @"?" : place.country;
            //Print the location to console
            DLog(@"LOCATION FOUND: %@", address);
            [self findWOEIDByAddressString:address];
        }
        else
        {
            [self analyticsLogGeocodingException:[NSString stringWithFormat:@"ERROR geocoding location: %@", [error description]]];
            UIAlertView *noLocationAlertView =
            [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_VIEW_LOCATION_ERROR_TITLE", @"Location Failed")
                                       message:NSLocalizedString(@"ALERT_VIEW_LOCATION_ERROR_MESSAGE", @"Location Failed")
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"OK", @"Ok")
                             otherButtonTitles:nil];
            [noLocationAlertView show];
            [self willSendLocationFailedNotification];
        }
    }];
}

#pragma mark - Yahoo Geocoding Service
- (void)findWOEIDByLocation:(CLLocation *)location
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if ((now - mLastLocationUpdateTime) > 120 || mCurrentLocation == nil)
    {
        mLocationUpdateCount++;
        mLastLocationUpdateTime = now;
        // gws2.maps.yahoo.com/findlocation?pf=1&locale=en_US&flags=J&offset=15&gflags=&q=Hasselt&start=0&count=100
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

- (void)findWOEIDByAddressString:(NSString *)address
{
    // gws2.maps.yahoo.com/findlocation?pf=1&locale=en_US&flags=J&offset=15&gflags=&q=Hasselt&start=0&count=100
    NSString *serviceURLString = [NSString stringWithFormat:@"%@?pf=1&locale=en_US&flags=J&offset=15&q=%@&gflags=%@&start=0&count=1",
                                  mWoeidServiceString,
                                  address,
                                  mWoeidServiceGFlags];
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

#pragma mark - NSURLConnectionDelegate Implementation
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode == 404)
        {
//            [connection cancel];  // stop connecting; no more delegate messages
            DLog(@"ERROR connection statuscode = %i", statusCode);
            [self analyticsLogGeocodingException:[NSString stringWithFormat:@"Location to WOEID service failed with HTTP status: %i", statusCode]];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[mResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	DLog(@"ERROR connection failed: %@", [error description]);
    [self analyticsLogGeocodingException:[NSString stringWithFormat:@"Location to WOEID service failed: %@", [error description]]];
    [self willSendLocationFailedNotification];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:mResponseData encoding:NSUTF8StringEncoding];
    DLog(@"Finished loading woeid response: \r %@", responseString);
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:mResponseData options:kNilOptions error:&error];
    NSObject *jsonObject = [(NSDictionary *)[jsonData objectForKey:@"ResultSet"] objectForKey:@"Results"];
    if ([jsonObject isKindOfClass:[NSArray class]])
    {
        NSDictionary *results = [(NSArray *)jsonObject objectAtIndex:0];
        self.woeid = [NSNumber numberWithInt:[[results objectForKey:@"woeid"] intValue]];
        [self willSendLocationSuccessNotification];
    }
    else if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *results = (NSDictionary *)jsonObject;
        self.woeid = [NSNumber numberWithInt:[[results objectForKey:@"woeid"] intValue]];
        [self willSendLocationSuccessNotification];
    }
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
        self.serviceTimer = [NSTimer scheduledTimerWithTimeInterval:WEATHER_SERVICE_CHECK_TIMER
                                                    target:self
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

#pragma mark - Google Analytics
- (void)analyticsLogGeocodingException:(NSString *)errorString
{
    if (ANALYTICS)
    {
        [[GAI sharedInstance].defaultTracker trackException:NO withDescription:errorString];
    }
}

@end
