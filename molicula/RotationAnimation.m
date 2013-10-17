//
//  RotationAnimation.m
//  molicula
//
//  Created by Eric Wolter on 10/12/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "RotationAnimation.h"
#import "Helper.h"

#define ANGULAR_VELOCITY 5.0f

@implementation RotationAnimation

@synthesize start;
@synthesize end;
@synthesize distance;
@synthesize progress;

-(id)initWithMolecule:(Molecule *)molecule AndTarget:(GLKQuaternion) target {
  self = [super initWithMolecule:molecule];
  if (self) {
    
    self.start = GLKQuaternionNormalize(self.molecule.orientation);
    self.end = GLKQuaternionNormalize(target);
    
    float innerProduct = [Helper GLKQuaternionInnerProductBetween:self.start and:self.end];
    
    self.distance = acosf((2.0f * innerProduct * innerProduct) - 1);
  }
  return self;
}

-(void)update:(NSTimeInterval)deltaT {
  if(isnan(self.distance) || self.distance < MIN_ANIMATION_DISTANCE) {
    self.progress = 1.0f;
    self.isDone = YES;
  } else {
    self.progress += (deltaT * ANGULAR_VELOCITY) / self.distance;
    if (self.progress > 1.0f) {
      self.progress = 1.0f;
      self.isDone = YES;
    }
  }
  self.molecule.orientation = GLKQuaternionSlerp(self.start, self.end, self.progress);
}

@end
