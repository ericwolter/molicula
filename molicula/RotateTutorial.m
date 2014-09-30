//
//  RotateMoleculeTutorial.m
//  molicula
//
//  Created by Eric Wolter on 09/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "RotateTutorial.h"
#import "Constants.h"
#import "Metrics.h"

@implementation RotateTutorial

-(id)init {
  if (self = [super init]) {
    self.weight = 750;
    self.text = @"Rotate by dragging on the left/right arrow";
    
    self.lasttime = 0;
    self.showCount = 0;
    self.amount = DEG_TO_RAD(240);
  }
  return self;
}

-(BOOL)checkIfApplicable {
  BOOL dontShowIfToEarly = (CACurrentMediaTime() - self.lasttime) > 60; //sec
  BOOL dontShowIfAlreadySurpassed = [Metrics sharedInstance].totalRotation < DEG_TO_RAD(960); // pixels
  BOOL dontShowIfAlreadyDone = self.showCount < 3;
  MLog(@"dontShowIfToEarly: %@", dontShowIfToEarly ? @"YES" : @"NO");
  MLog(@"dontShowIfAlreadySurpassed: %@", dontShowIfAlreadySurpassed ? @"YES" : @"NO");
  MLog(@"dontShowIfAlreadyDone: %@", dontShowIfAlreadyDone ? @"YES" : @"NO");
  return dontShowIfToEarly && dontShowIfAlreadySurpassed && dontShowIfAlreadyDone;
}

-(void)startReporting {
  MLog(@"start");
  [self.delegate tutorialWillAppear:self];
  
  self.showCount++;
  
  self.startValue = [Metrics sharedInstance].totalRotation;
  self.currentValue = self.startValue;
  [[Metrics sharedInstance] addObserver:self forKeyPath:@"totalRotation" options:NSKeyValueObservingOptionNew context:NULL];
}

-(void)stopReporting {
  MLog(@"start");
  [[Metrics sharedInstance] removeObserver:self forKeyPath:@"totalRotation"];
  self.lasttime = CACurrentMediaTime();
  
  [self.delegate tutorialWillDisappear:self];
}

@end
