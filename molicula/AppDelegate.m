//
//  AppDelegate.m
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import <RMAppReceipt.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [Crashlytics startWithAPIKey:@"bd56c9755da175dbceef21610d31133901bb338b"];
  
  self.receiptVerificator = [[RMStoreAppReceiptVerificator alloc] init];
  self.receiptVerificator.bundleIdentifier = @"com.ericwolter.molicula";
  self.receiptVerificator.bundleVersion = @"2.0.0";
  [RMStore defaultStore].receiptVerificator = self.receiptVerificator;
  BOOL verified = [self.receiptVerificator verifyAppReceipt];
  BOOL earlyAdopter = [[RMAppReceipt bundleReceipt].originalAppVersion hasPrefix:@"1"];
  
  UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
//
//  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//  UIViewController *gameViewController = [storyboard instantiateViewControllerWithIdentifier:@"GameViewController"];
//  
//  navigationController.viewControllers = [navigationController.viewControllers arrayByAddingObject:gameViewController];
//  [navigationController popToViewController:gameViewController animated:NO];
  
  [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
  navigationController.navigationBar.shadowImage = [UIImage new];
  navigationController.navigationBar.translucent = YES;
  
//  [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
//                                                       forBarMetrics:UIBarMetricsDefault];
//  [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
//                                                       forBarMetrics:UIBarMetricsLandscapePhone];
  
  // Override point for customization after application launch.
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
