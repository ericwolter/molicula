//
//  MoleculeFactory.m
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "MoleculeFactory.h"

@implementation MoleculeFactory

+ (Molecule *)blueMolecule {
  CGPoint atomCoordinates[MOLECULE_SIZE] = {
    CGPointMake(0, 2), CGPointMake(1, 1), CGPointMake(2, 0), CGPointMake(3, 0), CGPointMake(4, 0)
  };
  
  return [[Molecule alloc] initWithPoints:atomCoordinates andIdentifier:@"b"];
}

+ (Molecule *)yellowMolecule {
  CGPoint atomCoordinates[MOLECULE_SIZE] = {
    CGPointMake(0, 2), CGPointMake(0, 3), CGPointMake(1, 2), CGPointMake(2, 1), CGPointMake(3, 1)
  };
  
  return [[Molecule alloc] initWithPoints:atomCoordinates andIdentifier:@"y"];
}

+ (Molecule *)orangeMolecule {
  CGPoint atomCoordinates[MOLECULE_SIZE] = {
    CGPointMake(0, 2), CGPointMake(0, 3), CGPointMake(1, 2), CGPointMake(2, 1), CGPointMake(3, 1)
  };
  
  return [[Molecule alloc] initWithPoints:atomCoordinates andIdentifier:@"o"];
}

+ (Molecule *)greenMolecule {
  CGPoint atomCoordinates[MOLECULE_SIZE] = {
    CGPointMake(0, 2), CGPointMake(0, 3), CGPointMake(1, 1), CGPointMake(1, 2), CGPointMake(2, 0)
  };
  
  return [[Molecule alloc] initWithPoints:atomCoordinates andIdentifier:@"g"];
}

+ (Molecule *)whiteMolecule {
  CGPoint atomCoordinates[MOLECULE_SIZE] = {
    CGPointMake(0, 2), CGPointMake(0, 3), CGPointMake(1, 1), CGPointMake(1, 2), CGPointMake(2, 1)
  };
  
  return [[Molecule alloc] initWithPoints:atomCoordinates andIdentifier:@"w"];
}

+ (Molecule *)purpleMolecule {
  CGPoint atomCoordinates[MOLECULE_SIZE] = {
    CGPointMake(0, 2), CGPointMake(0, 3), CGPointMake(1, 1), CGPointMake(1, 2), CGPointMake(2, 1)
  };
  
  return [[Molecule alloc] initWithPoints:atomCoordinates andIdentifier:@"p"];
}

+ (Molecule *)redMolecule {
  CGPoint atomCoordinates[MOLECULE_SIZE] = {
    CGPointMake(0, 2), CGPointMake(1, 1), CGPointMake(2, 0), CGPointMake(3, -1), CGPointMake(3, 0)
  };
  
  return [[Molecule alloc] initWithPoints:atomCoordinates andIdentifier:@"r"];
}

@end

