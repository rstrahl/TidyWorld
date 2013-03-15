//
//  AppDelegate.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-01-27.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "cocos2d.h"
#import "AppDelegate.h"
#import "IntroLayer.h"
#import "LocationService.h"
#import "WeatherService.h"
#import "AlarmService.h"
#import "Constants.h"

@interface AppController()
/// Initialize Reachability service
- (void)initReachability;
/// Initialize Location service
- (void)initLocationService;
/// Initialize Weather service
- (void)initWeatherService;
/// Initialize Google Analytics
- (void)initGoogleAnalytics;
/// Initialize TestFlight
- (void)initTestFlight;
/// Notification Listener for Location Service
- (void)didReceiveLocationSuccessNotification:(NSNotification *)notification;
- (void)didReceiveLocationFailedNotification:(NSNotification *)notification;
/// Notification Listener for Weather Service
- (void)didReceiveWeatherSuccessNotification:(NSNotification *)notification;
- (void)didReceiveWeatherFailedNotification:(NSNotification *)notification;
// Google Analytics Logging
- (void)googleLogAppLoadingTime:(NSDate *)date;
@end

@implementation AppController

@synthesize window = window_,
            navController = navController_,
            director = director_,
            internetReachability = mInternetReachability,
            locationService = mLocationService,
            weatherService = mWeatherService,
            managedObjectContext = __managedObjectContext,
            managedObjectModel = __managedObjectModel,
            persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initalize Analytics
    [self initGoogleAnalytics];
    
    NSDate *startTime = [NSDate date];

    [self loadApplicationDefaults];
    [self initReachability];
    [self initWeatherService];
    [self initLocationService];
    
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	director_.wantsFullScreenLayout = YES;

	// Display FSP and SPF
	[director_ setDisplayStats:YES];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
	[director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ pushScene: [IntroLayer scene]]; 
	
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
//	[window_ addSubview:navController_.view];	// Generates flicker.
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
	
    [self initAlarmService];
    [self googleLogAppLoadingTime:startTime];
    
	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

#pragma mark - Application Defaults
- (void)loadApplicationDefaults
{
    // Set the application defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppDefaults" ofType:@"plist"]]];
    [defaults synchronize];
}

#pragma mark - Service Initialization
- (void)initReachability
{
    mInternetReachability = [Reachability reachabilityForInternetConnection];
}

- (void)initLocationService
{
    DLog(@"Initializing location service");
    
    if (mLocationService == nil)
    {
        mLocationService = [LocationService sharedInstance];
        mLocationService.delegate = self;
        mLocationService.internetReachable = mInternetReachability.currentReachabilityStatus;
        // Register notification listeners for service
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveLocationSuccessNotification:)
                                                     name:NOTIFICATION_LOCATION_SUCCESS
                                                   object:nil];
    }
}

- (void)initWeatherService
{
    DLog(@"Initializing weather service");
    if (mWeatherService == nil)
    {
        mWeatherService = [WeatherService sharedInstance];
        mWeatherService.internetReachable = mInternetReachability.currentReachabilityStatus;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveWeatherSuccessNotification:)
                                                     name:NOTIFICATION_WEATHER_SUCCESS
                                                   object:nil];
    }
}

- (void)initAlarmService
{
    DLog(@"Initializing alarm service");
    if (mAlarmService == nil)
    {
        mAlarmService = [AlarmService sharedInstance];
    }
}

#pragma mark - Analytics Initialization
- (void)initGoogleAnalytics
{
    // Optional: automatically track uncaught exceptions with Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = YES;
    // Create tracker instance.
    mGoogleTracker = [[GAI sharedInstance] trackerWithTrackingId:ANALYTICS_GOOGLE_TRACKING_ID];
    [GAI sharedInstance].defaultTracker = mGoogleTracker;
}

#pragma mark - TestFlight Initialization
- (void)initTestFlight
{
    // Initialize TestFlight
#ifdef TESTING
    NSLog(@"TestFlight initialization...");
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"bf713a672a32730f0c641e783f1b6ddf_NTEwNjkyMDEyLTAxLTAzIDE1OjEwOjE2LjE2NDQ0NA"];
#endif
}

#pragma mark - Reachability Delegate
- (void)didReceiveReachabilityChangedNotification:(NSNotification *)notification
{
    switch (mInternetReachability.currentReachabilityStatus) {
        case NotReachable:
        {
            self.locationService.internetReachable = NO;
            self.weatherService.internetReachable = NO;
            [self.locationService stopServiceTimer];
            break;
        }
        default:
        {
            self.locationService.internetReachable = YES;
            self.weatherService.internetReachable = YES;
            [self.locationService startServiceTimer];
            break;
        }
    }
}

#pragma mark - Service Notifications
- (void)didReceiveLocationSuccessNotification:(NSNotification *)notification
{
    [self.weatherService checkForWeatherUpdate];
}

- (void)didReceiveLocationFailedNotification:(NSNotification *)notification
{
    
}

- (void)didReceiveWeatherSuccessNotification:(NSNotification *)notification
{
    
}

- (void)didReceiveWeatherFailedNotification:(NSNotification *)notification
{
    
}

#pragma mark - Analytics Logging Methods
- (void)googleLogAppLoadingTime:(NSDate *)date
{
    if (ANALYTICS_GOOGLE_ON)
    {
        [mGoogleTracker trackTimingWithCategory:@"resources"
                                      withValue:fabs([date timeIntervalSinceNow])
                                       withName:@"AppLoadTime"
                                      withLabel:@"App Load Time"];
    }
}

#pragma mark - Core Data Helper Methods

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             TODO:
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Alarm" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Alarm.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

