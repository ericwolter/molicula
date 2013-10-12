//
//  BaseAnimation.h
//  molicula
//
//  Created by Eric Wolter on 10/12/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Molecule.h"

@interface BaseAnimation : NSObject

@property BOOL isDone;
@property Molecule *molecule;

-(id)initWithMolecule:(Molecule *)molecule;
-(void)update:(NSTimeInterval)deltaT;

@end
