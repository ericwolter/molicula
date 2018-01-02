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

@synthesize invertedModelViewMatrix;
@synthesize modelMatrix;
@synthesize objectMatrix;
@synthesize parent;
@synthesize modelViewMatrix;

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
  self.drawableDepthFormat = GLKViewDrawableDepthFormat16;
  self.drawableMultisample = GLKViewDrawableMultisample4X;
  
  self.effect = [[GLKBaseEffect alloc] init];
  [self setScaling:1.0f];
  self.molecules = [[NSMutableArray alloc] init];
  
  self.accessibilityElements = [[NSMutableArray alloc] init];
}

-(void)setScaling:(float)factor {
  self.modelViewMatrix = GLKMatrix4MakeScale(factor, factor, 1.0f);
  self.invertedModelViewMatrix = GLKMatrix4Invert(self.modelViewMatrix, nil);
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
  glClearColor(bg.x, bg.y,bg.z,bg.w);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  [self.grid render:self.effect];
  
  for (Molecule *molecule in self.molecules) {
    [molecule render:self.effect];
  }
}

/**
 * Converts a coordinate from the iOS viewspace to OpenGL coordinates.
 * UIKit has 0,0 in the upper left corner of the screen, with x increasing to the right and y to bottom.
 * The OpenGL coordinate system is, however centered. This means 0,0 is in the center of the view.
 * In this space x is increasing to the right and y is increasing upwards.
 *
 * @param viewCoordinate An coordinate in from iOS view.
 * @return An vector containing the OpenGL coordinate.
 */
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
  
  for (NSArray *column in self.grid.holes) {
    for (Hole *hole in column) {
      if (hole != (id)[NSNull null]) {
        hole.access = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        hole.access.accessibilityIdentifier = [NSString stringWithFormat:@"%d;%d", (int)hole.logicalPosition.x, (int)hole.logicalPosition.y];
        
        GLKVector2 holeWorldCoordinates = [self.grid getHoleWorldCoordinates:hole];
        
        CGFloat radius = GLKMatrix4MultiplyVector3(self.modelViewMatrix, GLKVector3Make(RENDER_RADIUS, 0.0f, 0.0f)).x;
        CGRect screenRect = self.bounds;
        CGRect holeRect = CGRectMake(holeWorldCoordinates.x - radius, holeWorldCoordinates.y - radius, radius * 2, radius * 2);
        holeRect = CGRectOffset(holeRect, screenRect.size.width/2, screenRect.size.height/2);
        holeRect.origin.y = screenRect.size.height - holeRect.origin.y - holeRect.size.height;
        
        hole.access.accessibilityFrame = holeRect;
        [self.accessibilityElements addObject:hole.access];
      }
    }
  }
}

- (void)disableGrid {
  if(self.grid) {
    [self.accessibilityElements removeObject:self.grid];
    self.grid = nil;
  }
}

- (BOOL)isAccessibilityElement {
  return NO;
}

- (NSInteger)accessibilityElementCount {
  return self.accessibilityElements.count;
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
  if (index < self.accessibilityElements.count) {
    return [self.accessibilityElements objectAtIndex:index];
  } else {
    return nil;
  }
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
  return [self.accessibilityElements indexOfObject:element];
}

- (void)addMolecule:(Molecule *)molecule {
  molecule.parent = self;
  [self.molecules addObject:molecule];
  molecule.access = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:molecule.parent];
  molecule.access.accessibilityIdentifier = molecule.identifer;
  [self.accessibilityElements addObject:molecule.access];
}

- (void)bringToFront:(NSInteger)moleculeIndex {
  Molecule *newFrontMostMolecule = [self.molecules objectAtIndex:moleculeIndex];
  [self.molecules removeObjectAtIndex:moleculeIndex];
  [self.molecules addObject:newFrontMostMolecule];
}

- (void)sendToBack:(NSInteger)moleculeIndex {
  Molecule *newBackMostMolecule = [self.molecules objectAtIndex:moleculeIndex];
  [self.molecules removeObjectAtIndex:moleculeIndex];
  [self.molecules insertObject:newBackMostMolecule atIndex:0];
}

- (void)sendToBackMolecule:(Molecule *)molecule {
  [self.molecules removeObject:molecule];
  [self.molecules insertObject:molecule atIndex:0];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular
      && self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
    [self setScaling:2.0f];
  } else {
    [self setScaling:1.0f];
  }
}

- (GLKMatrix4)calculateModelViewMatrix {
  return GLKMatrix4Identity;
}

@end
