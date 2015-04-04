//
//  MoveMoleculesTutorial.m
//  molicula
//
//  Created by Eric Wolter on 08/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "MoveTutorial.h"
#import "Constants.h"
#import "Metrics.h"

@implementation MoveTutorial

-(id)init {
  if (self = [super init]) {
    self.weight = 1000;
    self.text = @"Move molecules by dragging";
    
    self.lasttime = 0;
    self.showCount = 0;
    self.amount = 500;
  }
  return self;
}

-(BOOL)checkIfApplicable {
  BOOL dontShowIfToEarly = (CACurrentMediaTime() - self.lasttime) > 60; //sec
  BOOL dontShowIfAlreadySurpassed = [Metrics sharedInstance].totalTranslation < 2000; // pixels
  BOOL dontShowIfAlreadyDone = self.showCount < 2;
  return dontShowIfToEarly && dontShowIfAlreadySurpassed && dontShowIfAlreadyDone;
}

-(void)startReporting {
  [self.delegate tutorialWillAppear:self];
  
  self.showCount++;
  
  self.startValue = [Metrics sharedInstance].totalTranslation;
  self.currentValue = self.startValue;
  [[Metrics sharedInstance] addObserver:self forKeyPath:@"totalTranslation" options:NSKeyValueObservingOptionNew context:NULL];
}

-(void)stopReporting {
  [[Metrics sharedInstance] removeObserver:self forKeyPath:@"totalTranslation"];
  self.lasttime = CACurrentMediaTime();
  
  [self.delegate tutorialWillDisappear:self];
}

@end
