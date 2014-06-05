//
//  Metrics.m
//  molicula
//
//  Created by Eric Wolter on 05/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "Metrics.h"

@implementation Metrics

+ (Metrics *)sharedInstance
{
  //  Static local predicate must be initialized to 0
  static Metrics *sharedInstance = nil;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[Metrics alloc] init];
    // Do any other initialisation stuff here
  });
  return sharedInstance;
}

@end
