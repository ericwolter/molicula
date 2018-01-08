//
//  AppDelegate.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDiCloudSync.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, DDiCloudSyncDelegate>

@property (strong, nonatomic) UIWindow *window;
@property DDiCloudSync *cloudSync;

@property (strong, nonatomic) EAGLContext *context;

@end
