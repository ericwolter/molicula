//
//  TranslateAnimation.m
//  molicula
//
//  Created by Eric Wolter on 10/12/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "TranslateAnimation.h"

#define LINEAR_VELOCITY 200.0f

@implementation TranslateAnimation

@synthesize start;
@synthesize end;
@synthesize delta;
@synthesize distance;
@synthesize progress;

-(id)initWithMolecule:(Molecule *)molecule AndTarget:(GLKVector2) target {
  self = [super initWithMolecule:molecule];
  if (self) {
    
    self.start = self.molecule.position;
    self.end = target;
    
    self.delta = GLKVector2Subtract(self.end, self.start);
    self.distance = GLKVector2Length(self.delta);
  }
  return self;
}

-(void)update:(NSTimeInterval)deltaT {
  if(isnan(self.distance) || self.distance < MIN_ANIMATION_DISTANCE) {
    self.progress = 1.0f;
    self.isDone = YES;
  } else {
    self.progress += (deltaT * LINEAR_VELOCITY) / self.distance;
    if (self.progress > 1.0f) {
      self.progress = 1.0f;
      self.isDone = YES;
    }
  }
  self.molecule.position = GLKVector2Add(self.start, GLKVector2MultiplyScalar(self.delta, self.progress));
}

@end
