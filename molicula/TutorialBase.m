//
//  TutorialBase.m
//  molicula
//
//  Created by Eric Wolter on 08/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "TutorialBase.h"

@implementation TutorialBase

-(BOOL)checkIfApplicable {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

-(void)startReporting {
  [self doesNotRecognizeSelector:_cmd];
  return;
}

-(void)stopReporting {
  [self doesNotRecognizeSelector:_cmd];
  return;
}

-(BOOL)isFinished {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}


@end
