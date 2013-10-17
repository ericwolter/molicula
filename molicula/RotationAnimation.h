//
//  RotationAnimation.h
//  molicula
//
//  Created by Eric Wolter on 10/12/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "BaseAnimation.h"

@interface RotationAnimation : BaseAnimation

@property GLKQuaternion start;
@property GLKQuaternion end;
@property float distance;
@property float progress;

-(id)initWithMolecule:(Molecule *)molecule AndTarget:(GLKQuaternion) target;

@end
