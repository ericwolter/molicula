//
//  MoveMoleculesTutorial.m
//  molicula
//
//  Created by Eric Wolter on 08/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "MoveMoleculesTutorial.h"
#import "Metrics.h"
#import "Constants.h"

@implementation MoveMoleculesTutorial

-(id)init {
  if (self = [super init]) {
    self.weight = 1000;
    self.text = @"Move molecules by dragging";
  }
  return self;
}

-(BOOL)checkIfApplicable {
  BOOL dontShowIfToEarly = (CACurrentMediaTime() - lasttime) > 10; //sec
  BOOL dontShowIfAlreadySurpassed = [Metrics sharedInstance].totalTranslation < 2000; // pixels
  BOOL dontShowIfAlreadyDone = showCount < 2;
  MLog(@"dontShowIfToEarly: %@", dontShowIfToEarly ? @"YES" : @"NO");
  MLog(@"dontShowIfAlreadySurpassed: %@", dontShowIfAlreadySurpassed ? @"YES" : @"NO");
  MLog(@"dontShowIfAlreadyDone: %@", dontShowIfAlreadyDone ? @"YES" : @"NO");
  return dontShowIfToEarly && dontShowIfAlreadySurpassed && dontShowIfAlreadyDone;
}

double lasttime;
double showCount;
double start;
double current;
double percentage;
static const double amount = 500;

-(void)startReporting {
  MLog(@"start");
  [self.delegate tutorialWillAppear:self];
  
  showCount++;
  
  start = [Metrics sharedInstance].totalTranslation;
  current = start;
  [[Metrics sharedInstance] addObserver:self forKeyPath:@"totalTranslation" options:NSKeyValueObservingOptionNew context:NULL];
}

-(void)stopReporting {
  MLog(@"start");
  [[Metrics sharedInstance] removeObserver:self forKeyPath:@"totalTranslation"];
  lasttime = CACurrentMediaTime();
  
  [self.delegate tutorialWillDisappear:self];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  current = [(NSNumber *)change[@"new"] doubleValue];
  percentage =(current-start) / amount;
  MLog(@"percentage: %f", percentage);
  [self.delegate didProgressInTutorial:self toPercentage:percentage];
  
  if([self isFinished]) {
    [self stopReporting];
  }
}

-(BOOL)isFinished {
  return percentage > 1.0f;
}

@end
