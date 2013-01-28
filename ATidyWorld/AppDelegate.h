//
//  AppDelegate.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-01-27.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "Reachability.h"

@class LocationService;
@class WeatherService;

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow                    *window_;
	UINavigationController      *navController_;

	CCDirectorIOS               *director_;							// weak ref
    
    NSTimer                     *mServiceTimer;
    LocationService             *mLocationController;
    Reachability                *mInternetReachability;
    WeatherService              *mWeatherService;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (nonatomic, strong) NSTimer *serviceTimer;
@property (nonatomic, strong) LocationService *locationController;
@property (nonatomic, strong) Reachability *internetReachability;
@property (nonatomic, strong) WeatherService *weatherService;
@end
