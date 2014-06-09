//
//  Molecule.m
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "Molecule.h"
#import "Helper.h"
#import "NSValue_GLKVector.h"
#import "ColorTheme.h"
#import "GameView.h"
#import "Metrics.h"

@implementation Molecule

@synthesize atoms, color, identifer;
@synthesize position = _position;
@synthesize orientation = _orientation;

+ (CGPoint)mapToArrayIndices:(CGPoint)atomCoordinates {
  return CGPointMake(atomCoordinates.x, atomCoordinates.y + 1);
}

- (void)initializeAtoms {
  self.atoms = [[NSMutableArray alloc] initWithCapacity:GRID_WIDTH];
  for (int x = 0; x < GRID_WIDTH; x++) {
    NSMutableArray *column = [[NSMutableArray alloc] initWithCapacity:GRID_HEIGHT];
    for (int y = 0; y < GRID_HEIGHT; y++) {
      [column addObject:[[NSNull alloc] init]];
    }
    [self.atoms addObject:column];
  }
}

- (void)buildAtomsAt:(CGPoint *)atomCoordinates {
  
  self.center = GLKVector2Make(0, 0);
  
  for (int i = 0; i < MOLECULE_SIZE; i++) {
    CGPoint atomCoordinate = atomCoordinates[i];
    
    CGPoint arrayIndices = [Molecule mapToArrayIndices:atomCoordinate];
    NSMutableArray *column = [self.atoms objectAtIndex:arrayIndices.x];
    
    Atom *atom = [[Atom alloc] init];
    
    float x = HEXAGON_NARROW_WIDTH * atomCoordinate.x;
    float y = -HEXAGON_HEIGHT * (0.5 * atomCoordinate.x + atomCoordinate.y);
    
    atom.position = GLKVector2Make(x, y);
    self.center = GLKVector2Add(_center, atom.position);
    atom.parent = self;
    [column replaceObjectAtIndex:arrayIndices.y withObject:atom];
  }
  
  self.center = GLKVector2DivideScalar(_center, MOLECULE_SIZE);
}

- (NSMutableArray *)connectAtoms {
  NSMutableArray *bonds = [[NSMutableArray alloc] init];
  
  for (int x = 0; x < GRID_WIDTH; x++) {
    NSArray *column = [self.atoms objectAtIndex:x];
    for (int y = 0; y < GRID_HEIGHT; y++) {
      Atom *atom = [column objectAtIndex:y];
      if (atom != (id) [NSNull null]) {
        if (y - 1 >= 0) {
          Atom *north = [[self.atoms objectAtIndex:x] objectAtIndex:(y - 1)];
          if (north != (id) [NSNull null]) {
            [self setupBondVertices:bonds betweenAtom:atom andNeighbor:north];
          }
        }
        if (y - 1 >= 0 && x + 1 < GRID_WIDTH) {
          Atom *northEast = [[self.atoms objectAtIndex:(x + 1)] objectAtIndex:(y - 1)];
          if (northEast != (id) [NSNull null]) {
            [self setupBondVertices:bonds betweenAtom:atom andNeighbor:northEast];
          }
        }
        if (x + 1 < GRID_WIDTH && [[self.atoms objectAtIndex:(x + 1)] objectAtIndex:y] != [NSNull null]) {
          Atom *southEast = [[self.atoms objectAtIndex:(x + 1)] objectAtIndex:y];
          if (southEast != (id) [NSNull null]) {
            [self setupBondVertices:bonds betweenAtom:atom andNeighbor:southEast];
          }
        }
      }
    }
  }
  return bonds;
}

- (void)setupBondVertices:(NSMutableArray *)bonds betweenAtom:(Atom *)atom andNeighbor:(Atom *)neighbor {
  GLKVector2 fakeLine = [Helper fakeGLLineFrom:atom.position to:neighbor.position withWidth:BOND_WIDTH];
  GLKVector2 linePoints[NUMBER_OF_BOND_VERTICES] = {
    GLKVector2Subtract(atom.position, fakeLine),
    GLKVector2Add(atom.position, fakeLine),
    GLKVector2Add(neighbor.position, fakeLine),
    GLKVector2Subtract(neighbor.position, fakeLine)
  };
  [bonds addObject:[NSValue valueWithGLKVector2:GLKVector2Make(linePoints[0].x, linePoints[0].y)]];
  [bonds addObject:[NSValue valueWithGLKVector2:GLKVector2Make(linePoints[1].x, linePoints[1].y)]];
  [bonds addObject:[NSValue valueWithGLKVector2:GLKVector2Make(linePoints[2].x, linePoints[2].y)]];
  [bonds addObject:[NSValue valueWithGLKVector2:GLKVector2Make(linePoints[3].x, linePoints[3].y)]];
}

- (void)setupRenderingForBonds:(NSMutableArray *)bonds {
  numberOfBonds = [bonds count] / NUMBER_OF_BOND_VERTICES;
  bondPoints = malloc(sizeof(GLKVector2) * [bonds count]);
  for (NSUInteger i = 0; i < [bonds count]; i++) {
    bondPoints[i] = [[bonds objectAtIndex:i] GLKVector2Value];
  }
  
  bondIndices = malloc(sizeof(GLushort) * numberOfBonds * 6);
  for (int i = 0; i < numberOfBonds; i++) {
    bondIndices[i * 6 + 0] = (GLushort) (i * NUMBER_OF_BOND_VERTICES + 0);
    bondIndices[i * 6 + 1] = (GLushort) (i * NUMBER_OF_BOND_VERTICES + 1);
    bondIndices[i * 6 + 2] = (GLushort) (i * NUMBER_OF_BOND_VERTICES + 2);
    bondIndices[i * 6 + 3] = (GLushort) (i * NUMBER_OF_BOND_VERTICES + 0);
    bondIndices[i * 6 + 4] = (GLushort) (i * NUMBER_OF_BOND_VERTICES + 2);
    bondIndices[i * 6 + 5] = (GLushort) (i * NUMBER_OF_BOND_VERTICES + 3);
  }
}

- (id)initWithPoints:(CGPoint *)atomCoordinates andIdentifier:(NSString *)unique {
  if (self = [super init]) {
    [self initializeAtoms];
    
    [self buildAtomsAt:atomCoordinates];
    
    NSMutableArray *bonds = [self connectAtoms];
    
    [self setupRenderingForBonds:bonds];
    
    self.identifer = unique;
    
    self.color = [self mapIdentifierToColor];
    self.position = GLKVector2Make(0, 0);
    self.orientation = GLKQuaternionIdentity;
    
    [self updateObjectMatrix];
    
//    glGenBuffers(1, &boundingBoxBuffer);
//    glBindBuffer(GL_ARRAY_BUFFER, boundingBoxBuffer);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(boundingBoxVertices), boundingBoxVertices, GL_STATIC_DRAW);
//    glBindBuffer(GL_ARRAY_BUFFER, 0);
  }
  
  return self;
}

- (GLKVector4)mapIdentifierToColor {
  if ([self.identifer rangeOfString:@"b"].location != NSNotFound) {
    return [[ColorTheme sharedSingleton] blue];
  }
  if ([self.identifer rangeOfString:@"g"].location != NSNotFound) {
    return [[ColorTheme sharedSingleton] green];
  }
  if ([self.identifer rangeOfString:@"r"].location != NSNotFound) {
    return [[ColorTheme sharedSingleton] red];
  }
  if ([self.identifer rangeOfString:@"p"].location != NSNotFound) {
    return [[ColorTheme sharedSingleton] purple];
  }
  if ([self.identifer rangeOfString:@"o"].location != NSNotFound) {
    return [[ColorTheme sharedSingleton] orange];
  }
  if ([self.identifer rangeOfString:@"y"].location != NSNotFound) {
    return [[ColorTheme sharedSingleton] yellow];
  }
  if ([self.identifer rangeOfString:@"w"].location != NSNotFound) {
    return [[ColorTheme sharedSingleton] white];
  }
  
  return GLKVector4Make(1, 1, 1, 0.5f);
}

- (GLKMatrix4)GLKMatrix4MakeReflection:(GLKVector2)axis {
  float length_2 = 1 / powf(GLKVector2Length(axis), 2);
  
  GLKMatrix4 reflection = GLKMatrix4Make((powf(axis.x, 2) - powf(axis.y, 2)) / length_2, (2 * axis.x * axis.y) / length_2, 0, 0, (2 * axis.x * axis.y) / length_2, (powf(axis.y, 2) - powf(axis.x, 2)) / length_2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1);
  return reflection;
}

- (void)renderBonds:(GLKBaseEffect *)effect {
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, bondPoints);
  glDrawElements(GL_TRIANGLES, (GLsizei)(6 * numberOfBonds), GL_UNSIGNED_SHORT, bondIndices);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
}

- (void)renderAtoms:(GLKBaseEffect *)effect {
  for (NSArray *column in self.atoms) {
    for (Atom *atom in column) {
      if (atom != (id) [NSNull null]) {
        [atom render:effect];
      }
    }
  }
}

- (void)render:(GLKBaseEffect *)effect {
  GLKMatrix4 parentModelViewMatrix = [self.parent modelViewMatrix];
  self.modelViewMatrix = GLKMatrix4Multiply(parentModelViewMatrix, self.objectMatrix);
  
  effect.constantColor = self.color;
  effect.transform.modelviewMatrix = self.modelViewMatrix;
  [effect prepareToDraw];
  
  [self renderBonds:effect];
  [self renderAtoms:effect];
}

- (BOOL)hitTest:(GLKVector2)point {
  NSArray *worldPositions = [self getAtomPositionsInWorld];

  GLKMatrix4 parentModelViewMatrix = [self.parent modelViewMatrix];
  float radius = GLKMatrix4MultiplyVector3(parentModelViewMatrix, GLKVector3Make(HIT_RADIUS, 0.0f, 0.0f)).x;
  
  for(NSValue *value in worldPositions) {
    GLKVector2 position = [value GLKVector2Value];
    
    if (GLKVector2Distance(point, position) < radius)
    {
      return YES;
    }
  }
  
  return NO;
}

- (void)translate:(GLKVector2)translation {
  GLKMatrix4 invertedParentModelViewMatrix = [self.parent invertedModelViewMatrix];
  GLKVector4 objectTranslation = GLKMatrix4MultiplyVector4(invertedParentModelViewMatrix, GLKVector4Make(translation.x, translation.y, 0, 0));
  self.position = GLKVector2Add(self.position, GLKVector2Make(objectTranslation.x, objectTranslation.y));
  
  [self updateObjectMatrix];
}

- (void)setPosition:(GLKVector2)position {
  _position = position;
  [self updateObjectMatrix];
}

- (void)setOrientation:(GLKQuaternion)orientation {
  _orientation = orientation;
  [self updateObjectMatrix];
}

- (void)rotate:(CGFloat)angle {
  self.orientation = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(-angle, 0, 0, 1), self.orientation);
  self.orientation = GLKQuaternionNormalize(self.orientation);
  
  [self updateObjectMatrix];
}

- (GLKQuaternion)snapOrientation {
  // see: http://math.stackexchange.com/questions/90081/quaternion-distance
  const GLKQuaternion allowedOrientations[12] = {
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(60), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(120), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(240), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(300), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(60), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(120), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(240), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(300), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 1, 0))),
  };
  
  GLKQuaternion normOrientation = GLKQuaternionNormalize(self.orientation);
  
  int closestOrientationIndex = -1;
  float closestDistance = FLT_MAX;
  
  for (int i = 0; i < 12; i++) {
    GLKQuaternion allowedOrientation = allowedOrientations[i];
    float innerProduct =
      normOrientation.x * allowedOrientation.x +
      normOrientation.y * allowedOrientation.y +
      normOrientation.z * allowedOrientation.z +
      normOrientation.w * allowedOrientation.w;
    float distance = 1 - innerProduct * innerProduct;
    
    if (distance < closestDistance) {
      closestDistance = distance;
      closestOrientationIndex = i;
    }
  }
  
  return allowedOrientations[closestOrientationIndex];
}

-(void)mirror:(CGFloat)angle {
  self.orientation = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(angle, 0, 1, 0), self.orientation);
  
  [self updateObjectMatrix];
}

- (void)updateObjectMatrix {
  self.objectMatrix = [self makeObjectMatrixWithTranslation:self.position andOrientation:self.orientation];
}

- (CGRect)getWorldAABB {
  
  GLKMatrix4 parentModelViewMatrix = [self.parent modelViewMatrix];
  CGFloat renderRadiusInWorld = GLKMatrix4MultiplyVector3(parentModelViewMatrix, GLKVector3Make(RENDER_RADIUS, 0.0f, 0.0f)).x;
  
  // TODO: Combine getAtomPositionInWorld loops
  NSArray *worldCoordinateValues = [self getAtomPositionsInWorld];
  
  GLKVector2 aabbMin = GLKVector2Make(FLT_MAX, FLT_MAX);
  GLKVector2 aabbMax = GLKVector2Make(-FLT_MAX, -FLT_MAX);
//  NSLog(@"[start] aabbMin: %@", NSStringFromGLKVector2(aabbMin));
//  NSLog(@"[start] aabbMax: %@", NSStringFromGLKVector2(aabbMax));
  for (NSValue *worldCoordinateValue in worldCoordinateValues) {
    GLKVector2 atomWorldPosition = [worldCoordinateValue GLKVector2Value];
    
    if (atomWorldPosition.x < aabbMin.x) {
      aabbMin.x = atomWorldPosition.x;
    }
    if (atomWorldPosition.x > aabbMax.x) {
      aabbMax.x = atomWorldPosition.x;
    }
    
    if (atomWorldPosition.y < aabbMin.y) {
      aabbMin.y = atomWorldPosition.y;
    }
    if (atomWorldPosition.y > aabbMax.y) {
      aabbMax.y = atomWorldPosition.y;
    }
  }
  
  aabbMin = GLKVector2Subtract(aabbMin, GLKVector2Make(renderRadiusInWorld, renderRadiusInWorld));
  aabbMax = GLKVector2Add(aabbMax, GLKVector2Make(renderRadiusInWorld, renderRadiusInWorld));
  
//  NSLog(@"[end] aabbMin: %@", NSStringFromGLKVector2(aabbMin));
//  NSLog(@"[end] aabbMax: %@", NSStringFromGLKVector2(aabbMax));
  
  return CGRectMake(aabbMin.x, aabbMin.y, aabbMax.x-aabbMin.x, aabbMax.y-aabbMin.y);
}

- (GLKMatrix4)makeObjectMatrixWithTranslation:(GLKVector2)position andOrientation:(GLKQuaternion)orientation {
  GLKMatrix4 objectMatrix = GLKMatrix4Identity;
  objectMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-self.center.x, -self.center.y, 0.0f), objectMatrix);
  objectMatrix = GLKMatrix4Multiply(GLKMatrix4MakeScale(RENDER_RADIUS, RENDER_RADIUS, 1.0f), objectMatrix);
  objectMatrix = GLKMatrix4Multiply(GLKMatrix4MakeWithQuaternion(orientation), objectMatrix);
  objectMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(position.x, position.y, -500.0f), objectMatrix);
  
  return objectMatrix;
}

- (NSArray *)getAtomPositionsInWorld {
  NSMutableArray *worldCoordinates = [[NSMutableArray alloc] init];
  
  GLKMatrix4 parentModelViewMatrix = [self.parent modelViewMatrix];
  GLKMatrix4 screenTransformMatrix = GLKMatrix4Multiply(parentModelViewMatrix, self.objectMatrix);
  
  for (int x = 0; x < GRID_WIDTH; x++) {
    NSArray *column = [self.atoms objectAtIndex:x];
    for (int y = 0; y < GRID_HEIGHT; y++) {
      Atom *atom = [column objectAtIndex:y];
      if (atom != (id) [NSNull null]) {
        
        [worldCoordinates addObject:[NSValue valueWithGLKVector2:[self getAtomPositionInWorld:atom withTransform:screenTransformMatrix]]];
      }
    }
  }
  
  return worldCoordinates;
}

- (GLKVector2)getAtomPositionInWorld:(Atom *)atom withTransform:(GLKMatrix4)transformMatrix {
  GLKVector4 homogeneousCoordinate = GLKVector4Make(atom.position.x, atom.position.y, 0, 1);
  GLKVector4 homogeneousWorldCoordinate = GLKMatrix4MultiplyVector4(transformMatrix, homogeneousCoordinate);
  return GLKVector2Make(homogeneousWorldCoordinate.x/homogeneousWorldCoordinate.w, homogeneousWorldCoordinate.y/homogeneousWorldCoordinate.w);
}

- (GLKVector2)getAtomPositionInWorld:(Atom*)atom {
  GLKMatrix4 parentModelViewMatrix = [self.parent modelViewMatrix];
  GLKMatrix4 screenTransformMatrix = GLKMatrix4Multiply(parentModelViewMatrix, self.objectMatrix);
  return [self getAtomPositionInWorld:atom withTransform:screenTransformMatrix];
}

- (NSArray*)getAtomPositionsInWorldWithFutureOrientation:(GLKQuaternion)orientation {
  NSMutableArray *worldCoordinates = [[NSMutableArray alloc] init];
  
  GLKMatrix4 parentModelViewMatrix = [self.parent modelViewMatrix];
  GLKMatrix4 screenTransformMatrix = GLKMatrix4Multiply(parentModelViewMatrix, [self makeObjectMatrixWithTranslation:self.position andOrientation:orientation]);
  
  for (int x = 0; x < GRID_WIDTH; x++) {
    NSArray *column = [self.atoms objectAtIndex:x];
    for (int y = 0; y < GRID_HEIGHT; y++) {
      Atom *atom = [column objectAtIndex:y];
      if (atom != (id) [NSNull null]) {
        [worldCoordinates addObject:[NSValue valueWithGLKVector2:[self getAtomPositionInWorld:atom withTransform:screenTransformMatrix]]];
      }
    }
  }
  
  return worldCoordinates;
}

- (GLKVector4)getCenterInObjectSpace {
  GLKVector4 centerObjectSpace = GLKMatrix4MultiplyVector4(self.objectMatrix, GLKVector4Make(self.center.x, self.center.y, 0, 1));
  return centerObjectSpace;
}

- (GLKVector4)getCenterInParentSpace {
  GLKMatrix4 parentModelViewMatrix = [self.parent modelViewMatrix];
  GLKMatrix4 screenTransformMatrix = GLKMatrix4Multiply(parentModelViewMatrix, self.objectMatrix);

  return GLKMatrix4MultiplyVector4(screenTransformMatrix, GLKVector4Make(self.center.x, self.center.y, 0, 1));
}

- (void)snap:(GLKVector2)offset toHoles:(NSArray *)holes {
  self.isSnapped = YES;
  self.snappedHoles = holes;
  for (Hole *hole in self.snappedHoles) {
    hole.content = self;
  }
  
  [Metrics sharedInstance].snapCounter++;
}

- (void)unsnap {
  self.isSnapped = NO;
  for (Hole *hole in self.snappedHoles) {
    hole.content = nil;
  }
  self.snappedHoles = nil;
}

@end
