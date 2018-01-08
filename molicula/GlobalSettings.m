//
//  GlobalSettings.m
//  molicula
//
//  Created by Eric Wolter on 08.01.18.
//  Copyright © 2018 Eric Wolter. All rights reserved.
//

#import "GlobalSettings.h"

@implementation GlobalSettings

+ (GlobalSettings *)sharedInstance
{
  //  Static local predicate must be initialized to 0
  static GlobalSettings *sharedInstance = nil;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[GlobalSettings alloc] init];
    sharedInstance.isUITesting = NO;
  });
  return sharedInstance;
}

@end
