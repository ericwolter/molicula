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

@implementation Molecule

@synthesize atoms, color, identifer;
@synthesize position = _position;
@synthesize orientation = _orientation;
@synthesize center = _center;

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
  
  _center = GLKVector2Make(0, 0);
  
  for (int i = 0; i < MOLECULE_SIZE; i++) {
    CGPoint atomCoordinate = atomCoordinates[i];
    
    CGPoint arrayIndices = [Molecule mapToArrayIndices:atomCoordinate];
    NSMutableArray *column = [self.atoms objectAtIndex:arrayIndices.x];
    
    Atom *atom = [[Atom alloc] init];
    
    float x = HEXAGON_NARROW_WIDTH * atomCoordinate.x;
    float y = -HEXAGON_HEIGHT * (0.5 * atomCoordinate.x + atomCoordinate.y);
    
    atom.position = GLKVector2Make(x, y);
    _center = GLKVector2Add(_center, atom.position);
    atom.parent = self;
    [column replaceObjectAtIndex:arrayIndices.y withObject:atom];
  }
  
  _center = GLKVector2DivideScalar(_center, MOLECULE_SIZE);
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
    
    [self updateModelViewMatrix];
    [self updateAabb];
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

- (void)updateAabb {
  
  float minX = FLT_MAX;
  float minY = FLT_MAX;
  float maxX = -FLT_MAX;
  float maxY = -FLT_MAX;
  
  NSArray *worldPositions = [self getAtomPositionsInWorld];
  
  for(NSValue *value in worldPositions) {
    GLKVector2 position = [value GLKVector2Value];
    
    if(position.x < minX) {
      minX = position.x;
    }
    if(position.x > maxX) {
      maxX = position.x;
    }
    if(position.y < minY) {
      minY = position.y;
    }
    if(position.y > maxY) {
      maxY = position.y;
    }
  }
  
  self.aabbMin = GLKVector2Make(minX - RENDER_RADIUS, minY - RENDER_RADIUS);
  self.aabbMax = GLKVector2Make(maxX + RENDER_RADIUS, maxY + RENDER_RADIUS);
}

- (GLKMatrix4)GLKMatrix4MakeReflection:(GLKVector2)axis {
  float length_2 = 1 / powf(GLKVector2Length(axis), 2);
  
  GLKMatrix4 reflection = GLKMatrix4Make((powf(axis.x, 2) - powf(axis.y, 2)) / length_2, (2 * axis.x * axis.y) / length_2, 0, 0, (2 * axis.x * axis.y) / length_2, (powf(axis.y, 2) - powf(axis.x, 2)) / length_2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1);
  return reflection;
}

- (void)updateModelViewMatrix {
  self.modelViewMatrix = GLKMatrix4Identity;
  self.modelViewMatrix = GLKMatrix4Multiply(self.modelViewMatrix, GLKMatrix4MakeTranslation(-_center.x, -_center.y, 0));
  self.modelViewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeScale(RENDER_RADIUS, RENDER_RADIUS, 1.0f), self.modelViewMatrix);
  self.modelViewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeWithQuaternion(self.orientation), self.modelViewMatrix);
  self.modelViewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(self.position.x, self.position.y, -500.0f), self.modelViewMatrix);
}

- (void)renderBonds:(GLKBaseEffect *)effect {
  effect.transform.modelviewMatrix = self.modelViewMatrix;
  [effect prepareToDraw];
  
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, bondPoints);
  glDrawElements(GL_TRIANGLES, 6 * numberOfBonds, GL_UNSIGNED_SHORT, bondIndices);
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
  effect.constantColor = self.color;
  [self renderBonds:effect];
  [self renderAtoms:effect];
}

- (BOOL)hitTest:(CGPoint)point {
  if ( (point.x > self.aabbMin.x && point.y > self.aabbMin.y && point.x < self.aabbMax.x && point.y < self.aabbMax.y) )
  {
    NSArray *worldPositions = [self getAtomPositionsInWorld];
    
    for(NSValue *value in worldPositions) {
      GLKVector2 position = [value GLKVector2Value];
      GLKVector2 pointVector = GLKVector2Make(point.x, point.y);
      
      if (GLKVector2Distance(pointVector, position) < RENDER_RADIUS * 1.1f)
      {
        return YES;
      }
    }
    
    return NO;
  }
  else
  {
    return NO;
  }
}

- (void)translate:(GLKVector2)translation {
  self.position = GLKVector2Add(self.position, translation);
  
  [self updateModelViewMatrix];
  [self updateAabb];
}

- (void)setPosition:(GLKVector2)position {
  _position = position;
  
  [self updateModelViewMatrix];
  [self updateAabb];
}

- (void)rotate:(CGFloat)angle {
  self.orientation = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(-angle, 0, 0, 1), self.orientation);
  [self updateModelViewMatrix];
  [self updateAabb];
}

- (void)snapOrientation {
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
  
  self.orientation = allowedOrientations[closestOrientationIndex];
  
  [self updateModelViewMatrix];
  [self updateAabb];
}

-(void)mirror:(CGFloat)angle {
  self.orientation = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(angle, 0, 1, 0), self.orientation);
  
  [self updateModelViewMatrix];
  [self updateAabb];
}

- (NSArray *)getAtomPositionsInWorld {
  NSMutableArray *worldCoordinates = [[NSMutableArray alloc] init];
  
  for (int x = 0; x < GRID_WIDTH; x++) {
    NSArray *column = [self.atoms objectAtIndex:x];
    for (int y = 0; y < GRID_HEIGHT; y++) {
      Atom *atom = [column objectAtIndex:y];
      if (atom != (id) [NSNull null]) {
        GLKVector4 homogeneousCoordinate = GLKVector4Make(atom.position.x, atom.position.y, 0, 1);
        GLKVector4 homogeneousWorldCoordinate = GLKMatrix4MultiplyVector4(self.modelViewMatrix, homogeneousCoordinate);
        GLKVector2 worldCoordinate2d = GLKVector2Make(homogeneousWorldCoordinate.x/homogeneousWorldCoordinate.w, homogeneousWorldCoordinate.y/homogeneousWorldCoordinate.w);
        
        [worldCoordinates addObject:[NSValue valueWithGLKVector2:worldCoordinate2d]];
      }
    }
  }
  
  return worldCoordinates;
}

- (void)snap:(GLKVector2)offset toHoles:(NSArray *)holes {
  self.isSnapped = YES;
  self.snappedHoles = holes;
  for (Hole *hole in self.snappedHoles) {
    hole.content = self;
  }
  [self translate:offset];
}

- (void)unsnap {
  self.isSnapped = NO;
  for (Hole *hole in self.snappedHoles) {
    hole.content = nil;
  }
  self.snappedHoles = nil;
}

@end
