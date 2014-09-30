//
//  TutorialBase.m
//  molicula
//
//  Created by Eric Wolter on 08/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "TutorialBase.h"
#import "Constants.h"

@implementation TutorialBase

-(BOOL)checkIfApplicable {
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

-(void)startReporting {
  [self doesNotRecognizeSelector:_cmd];
  return;
}

-(void)stopReporting {
  [self doesNotRecognizeSelector:_cmd];
  return;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  self.currentValue = [(NSNumber *)change[@"new"] doubleValue];
  self.currentPercentage =(self.currentValue-self.startValue) / self.amount;
  MLog(@"percentage: %f", self.currentPercentage);
  [self.delegate didProgressInTutorial:self toPercentage:self.currentPercentage];
  
  if([self isFinished]) {
    [self stopReporting];
  }
}

-(BOOL)isFinished {
  return self.currentPercentage > 1.0f;
}

@end
