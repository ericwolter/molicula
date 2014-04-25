//
//  Molecule.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Hexagon.h"
#import "Atom.h"
#import "Grid.h"

@interface Molecule : NSObject {
  GLKVector2 *bondPoints;
  GLushort *bondIndices;
  int numberOfBonds;
}

@property id parent;

@property NSMutableArray *atoms;
@property(nonatomic, copy) NSString *identifer;
@property GLKVector4 color;
@property(nonatomic) GLKVector2 position;
@property(nonatomic) GLKQuaternion orientation;
@property(nonatomic) GLKVector2 center;
@property(nonatomic) BOOL isSnapped;
@property(nonatomic) NSArray *snappedHoles;
@property GLKVector2 aabbMin;
@property GLKVector2 aabbMax;

@property GLKMatrix4 objectMatrix;
@property GLKMatrix4 modelViewMatrix;
@property GLKMatrix4 worldTransformMatrix;

- (void)updateAabb;

- (void)render:(GLKBaseEffect *)effect;

- (void)updateModelViewMatrix;

- (BOOL)hitTest:(CGPoint)point;

- (void)snap:(GLKVector2)offset toHoles:(NSArray *)holes;

- (void)unsnap;

+ (CGPoint)mapToArrayIndices:(CGPoint)atomCoordinates;

- (id)initWithPoints:(CGPoint *)atomCoordinates andIdentifier:(NSString *)identifier;

- (GLKVector4)mapIdentifierToColor;

- (void)translate:(GLKVector2)translation;

- (void)rotate:(CGFloat)angle;
- (void)mirror:(CGFloat)angle;
- (GLKQuaternion)snapOrientation;

- (GLKMatrix4)buildModelViewMatrixWithMassCenter:(GLKVector2)massCenter andScalingFactor:(float)scalingFactor andOrientation:(GLKQuaternion)orientation andWorldPosition:(GLKVector2)worldPosition;
- (NSArray*)getAtomPositionsInWorld;
- (NSArray*)getAtomPositionsInWorldWithFutureOrientation:(GLKQuaternion)orientation;

@end
