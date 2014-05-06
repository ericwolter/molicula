//
//  GameView.m
//  molicula
//
//  Created by Eric Wolter on 24/04/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "GameView.h"
#import "ColorTheme.h"
#import "Molecule.h"

@interface GameView () {}

-(void)setup;

@end

@implementation GameView

- (id)init {
  if (self = [super init]) {
    [self setup];
  }
  
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self setup];
  }
  
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setup];
  }
  
  return self;
}

- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
  if (self = [super initWithFrame:frame context:context]) {
    [self setup];
  }
  
  return self;
}

- (void)setup {
  self.effect = [[GLKBaseEffect alloc] init];
  self.modelViewMatrix = GLKMatrix4MakeScale(0.5f, 0.5f, 1.0f);
  self.invertedModelViewMatrix = GLKMatrix4Invert(self.modelViewMatrix, nil);
  
  self.molecules = [[NSMutableArray alloc] init];
}

- (void)drawRect:(CGRect)rect {
  if (!self.delegate) {
    [self render];
  } else {
    [self.delegate glkView:self drawInRect:rect];
  }
}

- (void)render {
  GLKVector4 bg = [[ColorTheme sharedSingleton] bg];
  glClearColor(bg.x, 1.0f, bg.z, bg.w);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  [self.grid render:self.effect];

  for (Molecule *molecule in self.molecules) {
    [molecule render:self.effect];
  }
}

- (GLKVector2)convertViewCoordinateToOpenGLCoordinate:(CGPoint)viewCoordinate {
  return GLKVector2Make(viewCoordinate.x - self.bounds.size.width / 2, -(viewCoordinate.y - self.bounds.size.height / 2) );
}

- (void)updateProjection:(CGSize)size  {
  GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-size.width / 2, size.width / 2, -size.height / 2, size.height / 2, 0.0f, 1000.0f);
  self.effect.transform.projectionMatrix = projectionMatrix;
  [self.effect prepareToDraw];
}

- (void)enableGrid {
  self.grid = [[Grid alloc] init];
  self.grid.parent = self;
}

- (void)disableGrid {
  self.grid = nil;
}

- (void)addMolecule:(Molecule *)molecule {
  molecule.parent = self;
  [self.molecules addObject:molecule];
}

- (void)bringToFront:(NSInteger)moleculeIndex {
  Molecule *newFrontMostMolecule = [self.molecules objectAtIndex:moleculeIndex];
  [self.molecules removeObjectAtIndex:moleculeIndex];
  [self.molecules addObject:newFrontMostMolecule];
  
}

@end
