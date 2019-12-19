//
//  AppDelegate.m
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMobileAds/GADMobileAds.h>

#import "SolutionLibrary.h"
#import "GlobalSettings.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-ui_testing"]) {
    [GlobalSettings sharedInstance].isUITesting = YES;
  } else {
    [GlobalSettings sharedInstance].isUITesting = NO;
  }
  
  return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [GADMobileAds disableSDKCrashReporting];
  [SolutionLibrary sharedInstance];
  
  // make navigation bar transparent
  UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
  [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
  navigationController.navigationBar.shadowImage = [UIImage new];
  navigationController.navigationBar.translucent = YES;
  
  // Override point for customization after application launch.
  
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  
  if(NO == [GlobalSettings sharedInstance].isUITesting) {
    self.cloudSync = [DDiCloudSync sharedSync];
    self.cloudSync.delegate = [SolutionLibrary sharedInstance];
    [self.cloudSync start];
  }
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  if ([NSUbiquitousKeyValueStore defaultStore]) {
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
  } else {
    MLog(@"iCloud not enabled");
  }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
