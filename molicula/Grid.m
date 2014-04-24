//
//  Grid.m
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "Grid.h"
#import "ColorTheme.h"
#import "NSValue_GLKVector.h"

@implementation Grid

@synthesize holes;
@synthesize modelViewMatrix;

- (id)init {
  if (self = [super init]) {
    [self setupGrid];
  }
  
  return self;
}

- (void)setupGrid {
  self.holes = [[NSMutableArray alloc] initWithCapacity:GRID_WIDTH];
  for (int x = 0; x < GRID_WIDTH; x++) {
    NSMutableArray *column = [[NSMutableArray alloc] initWithCapacity:GRID_HEIGHT];
    for (int y = 0; y < GRID_HEIGHT; y++) {
      [column addObject:[[NSNull alloc] init]];
    }
    [self.holes addObject:column];
  }
  
  CGPoint holeCoordinates[NUMBER_OF_HOLES] = {
    CGPointMake(3, -1), CGPointMake(4, -1), CGPointMake(5, -1), CGPointMake(6, -1),
    CGPointMake(2, 0), CGPointMake(3, 0), CGPointMake(4, 0), CGPointMake(5, 0), CGPointMake(6, 0),
    CGPointMake(1, 1), CGPointMake(2, 1), CGPointMake(3, 1), CGPointMake(4, 1), CGPointMake(5, 1), CGPointMake(6, 1),
    CGPointMake(0, 2), CGPointMake(1, 2), CGPointMake(2, 2), CGPointMake(3, 2), CGPointMake(4, 2), CGPointMake(5, 2),
    CGPointMake(0, 3), CGPointMake(1, 3), CGPointMake(2, 3), CGPointMake(3, 3), CGPointMake(4, 3),
    CGPointMake(0, 4), CGPointMake(1, 4), CGPointMake(2, 4), CGPointMake(3, 4)
  };
  
  for (int i = 0; i < NUMBER_OF_HOLES; i++) {
    CGPoint holeCoordinate = holeCoordinates[i];
    
    CGPoint arrayIndices = [Grid mapToArrayIndices:holeCoordinate];
    
    NSMutableArray *column = [self.holes objectAtIndex:arrayIndices.x];
    
    Hole *hole = [[Hole alloc] init];
    
    float x = HEXAGON_NARROW_WIDTH * holeCoordinate.x;
    float y = -HEXAGON_HEIGHT * (0.5 * holeCoordinate.x + holeCoordinate.y);
    
    hole.position = GLKVector2Make(x, y);
    hole.parent = self;
    hole.logicalPosition = GLKVector2Make(holeCoordinate.x, holeCoordinate.y);
    [column replaceObjectAtIndex:arrayIndices.y withObject:hole];
  }
  
  float gridHeight = RENDER_HEX_HEIGHT * GRID_HEIGHT;
  float hexWidth = RENDER_HEX_HEIGHT / sinf(GLKMathDegreesToRadians(60));
  
  // -----   -----   -----   -----
  //     -----   -----   -----
  float gridWidth = GRID_WIDTH * hexWidth - (GRID_WIDTH - 1) * hexWidth / 4.0f;
  
  self.objectMatrix = GLKMatrix4MakeScale(RENDER_HEX_HEIGHT / 2.0f, RENDER_HEX_HEIGHT / 2.0f, 1.0f);
  self.objectMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-gridWidth / 2.0f + hexWidth / 2.0f, gridHeight / 2.0f, -500.0f), self.objectMatrix);
  self.modelViewMatrix = GLKMatrix4Identity;
}

- (void)render:(GLKBaseEffect *)effect {
  GLKMatrix4 parentModelViewMatrix = [self.parent modelViewMatrix];
  self.modelViewMatrix = GLKMatrix4Multiply(parentModelViewMatrix, self.objectMatrix);
  effect.constantColor = [[ColorTheme sharedSingleton] hole];

  NSLog(@"Grid render self: %@", NSStringFromGLKMatrix4(self.modelViewMatrix));
  NSLog(@"Grid render parent: %@", NSStringFromGLKMatrix4([self.parent modelViewMatrix]));
  NSLog(@"Grid render effect: %@", NSStringFromGLKMatrix4(effect.transform.modelviewMatrix));

  for (NSArray *column in self.holes) {
    for (id hole in column) {
      if (hole != [NSNull null]) {
        [hole render:effect];
      }
    }
  }
}

- (DropResult*)drop:(Molecule *)molecule withFutureOrientation:(GLKQuaternion)orientation {
  DropResult *result = [[DropResult alloc] init];
  result.isOverGrid = NO;
  result.molecule = molecule;
  
  result.holes = [[NSMutableArray alloc] initWithCapacity:molecule.atoms.count];
  
  // for each atom three possible scenarios are possible
  // 1. atom is not over the grid at all -> no drop result
  // 2. atom is over a filled hole -> no drop result
  // 3. atom is over an empty hole -> drop result
  for(NSValue *wrappedAtomWorldCoordinate in [molecule getAtomPositionsInWorldWithFutureOrientation:orientation]) {
    GLKVector2 atomWorldCoordinate = [wrappedAtomWorldCoordinate GLKVector2Value];
    
    BOOL isAtomOverGrid = NO;
    
    // iterate over the 2-dimensional holes array
    for (NSArray *column in self.holes) {
      for (Hole *hole in column) {
        if(hole != (id)[NSNull null]) {
          
          // how far away is the atom from the hole in world coordinates
          GLKVector2 offset = GLKVector2Subtract([self getHoleWorldCoordinates:hole], atomWorldCoordinate);
          if(GLKVector2Length(offset) < RENDER_HEX_HEIGHT / 2.0f) {
            
            // check if the hole is already filled, if yes we can end the complete check
            // if only a single atom can not be dropped the complete molecule also can't
            if(hole.content) {
              result.isOverGrid = NO;
              return result;
            }
            result.offset = GLKVector2Make(offset.x, offset.y);
            [result.holes addObject:hole];
            
            isAtomOverGrid = YES;
            break;
          }
        }
      }
      
      if(isAtomOverGrid) {
        break;
      }
    }
    
    // check if the hole is even above the grid, if not we can end the complete check
    // if only a single atom is not over the grid, the complete molecule can't be dropped
    if (!isAtomOverGrid) {
      result.isOverGrid = NO;
      return result;
    }
  }
  
  result.isOverGrid = YES;
  return result;
}

- (GLKVector2)getHoleWorldCoordinates:(Hole *)hole {
  
  GLKVector4 homogeneousCoordinate = GLKVector4Make(hole.position.x, hole.position.y, 0, 1);
  GLKVector4 homogeneousWorldCoordinate = GLKMatrix4MultiplyVector4(self.modelViewMatrix, homogeneousCoordinate);
  
  return GLKVector2Make(homogeneousWorldCoordinate.x/homogeneousWorldCoordinate.w, homogeneousWorldCoordinate.y/homogeneousWorldCoordinate.w);
}

- (bool)isFilled {
  for (NSArray *column in self.holes) {
    for (Hole *hole in column) {
      if (hole != (id)[NSNull null]) {
        if (!hole.content) {
          return NO;
        }
      }
    }
  }
  return YES;
}

+ (CGPoint)mapToArrayIndices:(CGPoint)gridCoordinates {
  return CGPointMake(gridCoordinates.x, gridCoordinates.y + 1);
}

+ (CGPoint)mapToGridCoordinates:(CGPoint)arrayIndices {
  return CGPointMake(arrayIndices.x, arrayIndices.y - 1);
}

-(NSString*)toString {
  NSMutableString *solution = [[NSMutableString alloc] init];
  for (NSArray *column in self.holes) {
    for (Hole *hole in column) {
      if (hole != (id)[NSNull null]) {
        if (hole.content == nil) {
          [solution appendString:@"-"];
        } else {
          [solution appendString:((Molecule *)hole.content).identifer];
        }
      } else {
        [solution appendString:@"0"];
      }
    }
  }
  return solution;
}


@end
