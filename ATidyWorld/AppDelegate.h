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
#import <AVFoundation/AVFoundation.h>
#import "AlarmService.h"

@class LocationService;
@class WeatherService;

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate, AlarmServiceDelegate>
{
	UIWindow                    *window_;
	UINavigationController      *navController_;

	CCDirectorIOS               *director_;							// weak ref
    
    LocationService             *mLocationService;
    Reachability                *mInternetReachability;
    WeatherService              *mWeatherService;
    AlarmService                *mAlarmService;
    // Audio Components
    AVPlayer                    *mAudioPlayer;
    BOOL                        mAudioPlaying;
    id<GAITracker>              mGoogleTracker;
}

@property (nonatomic, retain) UIWindow                                  *window;
@property (readonly) UINavigationController                             *navController;
@property (readonly) CCDirectorIOS                                      *director;
@property (nonatomic, strong) LocationService                           *locationService;
@property (nonatomic, strong) Reachability                              *internetReachability;
@property (nonatomic, strong) WeatherService                            *weatherService;
@property (nonatomic, strong) AlarmService                              *alarmService;
@property (nonatomic, strong) AVPlayer                                  *audioPlayer;

@property (nonatomic, strong, readonly) NSManagedObjectModel            *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext          *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

// Core Data Methods
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
