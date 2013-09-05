//
//  Grid.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hexagon.h"
#import "Hole.h"
#import "Molecule.h"

@class Molecule;

static const float RENDER_HEX_HEIGHT = 60.0f;
static const float RENDER_RADIUS = RENDER_HEX_HEIGHT / 2.0f;

static const int GRID_WIDTH = 7;
static const int GRID_HEIGHT = 6;
static const int NUMBER_OF_HOLES = 30;

static const int BORDER_RESOLUTION = CIRCLE_RESOLUTION / 2;
static const float BORDER_WIDTH = 1.3f;

@interface Grid : NSObject {
  GLKVector2 borderPoints[6 * BORDER_RESOLUTION + 2];
}

@property NSMutableArray *holes;
@property GLKMatrix4 modelViewMatrix;

- (void)setupGrid;
- (void)render:(GLKBaseEffect *)effect;
- (bool)snapMolecule:(Molecule *)molecule;
- (bool)isFilled;

- (GLKVector2)getHoleWorldCoordinates:(Hole *)hole;
- (NSString*)toString;

+ (CGPoint)mapToArrayIndices:(CGPoint)gridCoordinates;

@end
