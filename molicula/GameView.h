//
//  GameView.h
//  molicula
//
//  Created by Eric Wolter on 24/04/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "Grid.h"

@interface GameView : GLKView {
}

@property (strong, nonatomic) GLKBaseEffect *effect;
@property (nonatomic) GLKMatrix4 modelViewMatrix;
@property (nonatomic) GLKMatrix4 invertedModelViewMatrix;

@property (strong, nonatomic) Grid *grid;
@property (strong, nonatomic) NSMutableArray *molecules;
@property (assign) CGFloat projectionWidth;
@property (assign) CGFloat projectionHeight;

- (void)setScaling:(float)factor;
- (void)render;
- (void)updateProjection:(CGSize)size;

- (void)enableGrid;
- (void)disableGrid;

- (void)addMolecule:(Molecule *)molecule;

- (GLKVector2)convertViewCoordinateToOpenGLCoordinate:(CGPoint)viewCoordinate;
- (void)bringToFront:(NSInteger)moleculeIndex;
- (void)sendToBack:(NSInteger)moleculeIndex;
- (void)sendToBackMolecule:(Molecule *)molecule;

@end
