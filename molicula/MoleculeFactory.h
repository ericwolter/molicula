//
//  MoleculeFactory.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Molecule.h"

@interface MoleculeFactory : NSObject

+ (Molecule *)blueMolecule;
+ (Molecule *)yellowMolecule;
+ (Molecule *)orangeMolecule;
+ (Molecule *)greenMolecule;
+ (Molecule *)whiteMolecule;
+ (Molecule *)purpleMolecule;
+ (Molecule *)redMolecule;

@end
