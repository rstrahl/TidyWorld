//
//  CoreLocationController.h
//  A Tidy World
//
//  Created by Rudi Strahl on 11-09-10.
//  Copyright 2011 Rudi Strahl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>

@interface LocationService : NSObject <NSURLConnectionDelegate, CLLocationManagerDelegate>
{
    @private
    CLLocationManager                           *mLocationManager;
    CLLocation                                  *mCurrentLocation;
    CLGeocoder                                  *mGeocoder;
	id __unsafe_unretained                      mDelegate;
    NSTimer                                     *mServiceTimer;
    BOOL                                        mRunning;
    NSMutableData                               *mResponseData;
    NSNumber                                    *mWoeid;
    NSURL                                       *mWoeidServiceURL;
    NSString                                    *mWoeidServiceString;
    NSString                                    *mWoeidServiceGFlags;
    NSString                                    *mWoeidServiceFlags;
    NSString                                    *mYahooApplicationID;
    NSString                                    *mCity;
    NSString                                    *mState;
    NSString                                    *mCountry;
    NSTimeInterval                              mLastLocationUpdateTime;
    BOOL                                        mInternetReachable;
}

@property (nonatomic, strong) CLLocationManager             *locationManager;
@property (nonatomic, unsafe_unretained) id                 delegate;
@property (nonatomic, strong) CLLocation                    *currentLocation;
@property (nonatomic, strong) NSNumber                      *woeid;
@property (nonatomic, strong) NSString                      *city;
@property (nonatomic, strong) NSString                      *state;
@property (nonatomic, strong) NSString                      *country;
@property (nonatomic, strong) NSTimer                       *serviceTimer;
@property (nonatomic, assign, getter = isRunning)           BOOL running;
@property (nonatomic, assign, getter = isInternetReachable) BOOL internetReachable;

/// Return a reference to the LocationService singleton instance
+ (id)sharedInstance;
/// Start the location service
- (void)start;
/// Start the location service timer
- (void)startServiceTimer;
/// Stop the location service timer
- (void)stopServiceTimer;

@end
