//
//  AppDelegate.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RMStoreAppReceiptVerificator.h>
#import <RMStoreKeychainPersistence.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property RMStoreAppReceiptVerificator *receiptVerificator;
@property RMStoreKeychainPersistence *persistor;

@property (strong, nonatomic) EAGLContext *context;

@end
