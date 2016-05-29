
//  AppDelegate.m
//  Voices
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "AppDelegate.h"
#import "PageViewController.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworkReachabilityManager.h"
#import "OnboardingNavigationController.h"
#import "Onboarding2ViewController.h"
#import "SSZipArchive.h"
#import "VoicesConstants.h"
#import "RepManager.h"
#import "NewsFeedManager.h"
//#import <Google/Analytics.h>
@import Firebase;
@import FirebaseMessaging;



@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
   // [self initializeParseWithApplication:application];
    [self setInitialViewController];
    [self setCache];
    [self enableFeedbackAndReporting];
    [self unzipNYCDataSet];
    [self excludeGeoJSONFromCloudBackup];
    [FIRApp configure];

    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (notificationPayload) {
        [[NewsFeedManager sharedInstance]createCallToActionFromNotificationPayload:[[notificationPayload valueForKey:@"aps"]valueForKey:@"alert"]];
    }

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Pring full message.
    NSLog(@"%@", userInfo);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

# pragma mark - AppDidFinishLaunchingConfiguration

//- (void)initializeParseWithApplication:(UIApplication *)application {
//    // Initialize Parse.
//    [Parse setApplicationId:@"msKZQRGc37A1UdBdxGO1WdJa0dmyuXz61m7O4qPO"
//                  clientKey:@"tApEQQS6ygoaRC6UM4H7jtdzknUZiL8LfT88fjmr"];
//    
//    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
//                                                    UIUserNotificationTypeBadge |
//                                                    UIUserNotificationTypeSound);
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
//                                                                             categories:nil];
//    [application registerUserNotificationSettings:settings];
//    [application registerForRemoteNotifications];
//}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
//    PFInstallation *installation = [PFInstallation currentInstallation];
//    [installation setDeviceTokenFromData:deviceToken];
//    installation.channels = @[ @"global" ];
//    [installation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Not sure what this is.
    //[PFPush handlePush:userInfo];
    [[NewsFeedManager sharedInstance]createCallToActionFromNotificationPayload:[[userInfo valueForKey:@"aps"]valueForKey:@"alert"]];

}

- (void)setInitialViewController {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        // The app is launching for the first time
        NSLog(@"First launch");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIStoryboard *onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle: nil];
        OnboardingNavigationController *onboardingPageViewController = (OnboardingNavigationController*)[onboardingStoryboard instantiateViewControllerWithIdentifier: @"OnboardingNavigationController"];
        self.window.rootViewController = onboardingPageViewController;
        [self.window makeKeyAndVisible];
    }
    else if (![self isOnboardingCompleted]) {
        // User did not complete onboarding
        UIStoryboard *onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle: nil];
        Onboarding2ViewController *onboardingPageViewController = (Onboarding2ViewController *)[onboardingStoryboard instantiateViewControllerWithIdentifier: @"Onboarding2ViewController"];
        self.window.rootViewController = onboardingPageViewController;
        [self.window makeKeyAndVisible];
    }
}

- (BOOL)isOnboardingCompleted {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isOnboardingCompleted"]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)enableFeedbackAndReporting {
    // Override point for customization after application launch.
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    
    // Configure tracker from GoogleService-Info.plist.
//    NSError *configureError;
//    [[GGLContext sharedInstance] configureWithError:&configureError];
//    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
//    GAI *gai = [GAI sharedInstance];
//    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
//    gai.logger.logLevel = kGAILogLevelNone;  // remove before app release
}

- (void)setCache {
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024
                                                            diskCapacity:100 * 1024 * 1024
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
}

- (void)unzipNYCDataSet {
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kCityCouncilZip]) {
        [RepManager sharedInstance].nycDistricts = [[[NSUserDefaults standardUserDefaults]objectForKey:kCityCouncilZip]valueForKey:@"features"];
        
    }
    else {
        // Get the file path for the zip
        NSString *archiveFilePath = [[NSBundle mainBundle] pathForResource:kCityCouncilZip ofType:@"zip"];
        // Get the file path for the destination
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        // Specify that we want the council data set
        self.dataSetPathWithComponent = [documentsPath stringByAppendingPathComponent:kCityCouncilJSON];
        // Check if the file exists at the path
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.dataSetPathWithComponent];
        // If the file does not already exist, unzip it
        if (!fileExists) {
            // Unzip the archive and send it to destination
            [SSZipArchive unzipFileAtPath:archiveFilePath toDestination:documentsPath];
        }
        
        NSString *myJSON = [[NSString alloc] initWithContentsOfFile:((AppDelegate*)[UIApplication sharedApplication].delegate).dataSetPathWithComponent encoding:NSUTF8StringEncoding error:NULL];
        NSError *error =  nil;
        NSDictionary *jsonDataDict = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        [[NSUserDefaults standardUserDefaults]setObject:jsonDataDict forKey:kCityCouncilZip];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [RepManager sharedInstance].nycDistricts = [jsonDataDict valueForKey:@"features"];
    }
}

- (void)excludeGeoJSONFromCloudBackup {
    // Exclude files from iCloud backup
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSArray *documents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:nil];
    NSURL *URL;
    NSString *completeFilePath;
    for (NSString *file in documents) {
        completeFilePath = [NSString stringWithFormat:@"%@/%@", basePath, file];
        URL = [NSURL fileURLWithPath:completeFilePath];
        [URL setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
       // NSLog(@"File %@  is excluded from backup %@", file, [URL resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsExcludedFromBackupKey] error:nil]);
    }
}

- (void)printFontFamilies {
    for (NSString *familyName in [UIFont familyNames]){
        NSLog(@"Family name: %@", familyName);
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"--Font name: %@", fontName);
        }
    }
}

// Remove Apple bug error warning that occurs when phone call occurs
- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
    for(UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if([window.class.description isEqual:@"UITextEffectsWindow"]) {
            [window removeConstraints:window.constraints];
        }
    }
}

@end