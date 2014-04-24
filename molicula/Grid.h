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
#import "DropResult.h"

@interface Grid : NSObject

@property id parent;

@property NSMutableArray *holes;
@property GLKMatrix4 modelViewMatrix;
@property GLKMatrix4 objectMatrix;

- (void)setupGrid;
- (void)render:(GLKBaseEffect *)effect;
- (DropResult*)drop:(Molecule *)molecule withFutureOrientation:(GLKQuaternion)orientation;
- (bool)isFilled;

- (GLKVector2)getHoleWorldCoordinates:(Hole *)hole;
- (NSString*)toString;

+ (CGPoint)mapToArrayIndices:(CGPoint)gridCoordinates;

@end
