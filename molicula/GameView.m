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

@implementation GameView

- (id)init {
  if (self = [super init]) {
    self.effect = [[GLKBaseEffect alloc] init];
    self.modelViewMatrix = GLKMatrix4MakeScale(0.5f, 0.5f, 1.0f);
    
    self.molecules = [[NSMutableArray alloc] init];
  }
  
  return self;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
  GLKVector4 bg = [[ColorTheme sharedSingleton] bg];
  glClearColor(1.0f, bg.y, bg.z, bg.w);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  [self.grid render:self.effect];
  
  for (Molecule *molecule in self.molecules) {
    [molecule render:self.effect];
  }
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

@end
