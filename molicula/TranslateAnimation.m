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

@synthesize end = _end;
@synthesize velocity = _velocity;

-(id)initWithMolecule:(Molecule *)molecule AndTranslation:(GLKVector2) translationVector; {
  self = [super initWithMolecule:molecule];
  if (self) {
    self.end = GLKVector2Add(self.molecule.position, translationVector);
    self.velocity = GLKVector2MultiplyScalar(GLKVector2Normalize(translationVector), LINEAR_VELOCITY);
  }
  return self;
}

-(void)update:(NSTimeInterval)deltaT {
  GLKVector2 deltaX = GLKVector2MultiplyScalar(self.velocity, deltaT);
  
  GLKVector2 remaining = GLKVector2Subtract(self.end, self.molecule.position);
  
  if (GLKVector2Length(deltaX) > GLKVector2Length(remaining)) {
    deltaX = remaining;
    self.isDone = YES;
  }
  
  [self.molecule translate:deltaX];
}

@end
