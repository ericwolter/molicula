//
//  GlobalSettings.h
//  molicula
//
//  Created by Eric Wolter on 08.01.18.
//  Copyright © 2018 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalSettings : NSObject

@property BOOL isUITesting;

+ (GlobalSettings *)sharedInstance;

@end
