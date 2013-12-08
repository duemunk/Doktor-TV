//
//  AppDelegate.m
//  Doktor TV
//
//  Created by Tobias DM on 13/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

#import "DataHandler.h"
#import "DRHandler.h"
#import "FileDownloadHandler.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	DLog(@"WillLaunch");
	return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	DLog(@"DidLaunch");
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
	
	self.window.rootViewController = [MainViewController new];
	self.window.tintColor = mainColor;
	
    [self.window makeKeyAndVisible];
	
	[[DataHandler sharedInstance] cleanUpCachedLocalFiles];
	
#if DEBUG
	[FileDownloadHandler sharedInstance];
#endif
	
	// Allow app to wake up and do background fetches
	[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	DLog(@"ResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	DLog(@"EnterBackground");
	
	[[DataHandler sharedInstance] saveContext];	
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	DLog(@"EnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	DLog(@"BecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	
	[[DataHandler sharedInstance] saveContext];
}



- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
	DLog(@"backgroundURLSession %@",identifier);
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	// Background fetch – called after application:didFinishLaunchingWithOptions:
	[[DRHandler sharedInstance] refreshMainData:^(BOOL didReceiveNewData) {
		// Call completionHandler when finished...
		if (didReceiveNewData) {
			completionHandler(UIBackgroundFetchResultNewData);
		} else {
			completionHandler(UIBackgroundFetchResultNoData);
		}
	}];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	// TODO: Use for remote notifications telling about new content
	// aps { content-available: 1, alert: {...} } 
	DLog(@"%@",userInfo);
}
@end
