//
//  Animator.m
//  molicula
//
//  Created by Eric Wolter on 10/12/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "Animator.h"
#import "BaseAnimation.h"

@implementation Animator

@synthesize runningAnimation;

-(id)init {
  self = [super init];
  if(self) {
    self.runningAnimation = [[NSMutableArray alloc] init];
  }
  return self;
}

-(void)update:(NSTimeInterval)deltaT {
  
  for (NSUInteger i = 0; i < [runningAnimation count]; i++) {
    BaseAnimation *animation = [runningAnimation objectAtIndex:i];
    
    [animation update:deltaT];
    
    if (animation.isDone) {
      [runningAnimation removeObjectAtIndex:i];
      i--;
    }
  }
}

-(BOOL)hasRunningAnimation {
  return [self.runningAnimation count] != 0;
}

@end
