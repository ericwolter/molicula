//
//  BaseAnimation.m
//  molicula
//
//  Created by Eric Wolter on 10/12/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "BaseAnimation.h"

@implementation BaseAnimation

@synthesize molecule = _molecule;
@synthesize isDone = _isDone;

-(id)initWithMolecule:(Molecule *)molecule {
  self = [super init];
  if(self) {
    self.isDone = NO;
    self.molecule = molecule;
  }
  return self;
}

-(void)update:(NSTimeInterval)deltaT {}

@end
