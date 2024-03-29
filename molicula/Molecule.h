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

@interface Molecule : GLModel {
  GLKVector2 *bondPoints;
  GLushort *bondIndices;
  NSInteger numberOfBonds;
}

@property NSMutableArray *atoms;
@property(nonatomic, copy) NSString *identifer;
@property GLKVector4 color;
@property(nonatomic) GLKVector2 position;
@property(nonatomic) GLKQuaternion orientation;
@property(nonatomic) GLKVector2 center;
@property(nonatomic) BOOL isSnapped;
@property(nonatomic) NSArray *snappedHoles;

@property UIAccessibilityElement *access;

- (UIColor *)getUIColor;

- (void)render:(GLKBaseEffect *)effect;

- (BOOL)hitTest:(GLKVector2)point;

- (BOOL)snap:(GLKVector2)offset toHoles:(NSArray *)holes;

- (BOOL)unsnap;

+ (CGPoint)mapToArrayIndices:(CGPoint)atomCoordinates;

- (id)initWithPoints:(CGPoint *)atomCoordinates andIdentifier:(NSString *)identifier;

- (GLKVector4)mapIdentifierToColor;

- (GLKVector4)getCenterInObjectSpace;
- (GLKVector4)getCenterInParentSpace;

- (void)translate:(GLKVector2)translation;
- (void)rotate:(CGFloat)angle;
- (void)mirror:(CGFloat)angle;
- (GLKQuaternion)snapOrientation;

- (GLKMatrix4)makeObjectMatrixWithTranslation:(GLKVector2)position andOrientation:(GLKQuaternion)orientation;
- (void)updateObjectMatrix;
- (CGRect)getWorldAABB;
- (CGRect)getWorldAABBWithTranslation:(GLKVector2)translation andOrientation:(GLKQuaternion)orientation;

- (NSArray*)getAtomPositionsInWorld;
- (NSArray*)getAtomPositionsInWorldWithFutureTranslation:(GLKVector2)translation andFutureOrientation:(GLKQuaternion)orientation;
- (GLKVector2)getAtomPositionInWorld:(Atom*)atom;
- (GLKVector2)getAtomPositionInWorld:(Atom *)atom withTransform:(GLKMatrix4)transformMatrix;

@end
