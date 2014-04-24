//
//  GameView.m
//  molicula
//
//  Created by Eric Wolter on 24/04/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "GameView.h"
#import "ColorTheme.h"

@implementation GameView

- (id)init {
  if (self = [super init]) {
    self.effect = [[GLKBaseEffect alloc] init];
    
    self.modelViewMatrix = GLKMatrix4MakeScale(1.0f, 1.0f, 1.0f);
    NSLog(@"GameView init: %@", NSStringFromGLKMatrix4(self.modelViewMatrix));
  }
  
  return self;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
  GLKVector4 bg = [[ColorTheme sharedSingleton] bg];
  glClearColor(1.0f, bg.y, bg.z, bg.w);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  NSLog(@"GameView render self: %@", NSStringFromGLKMatrix4(self.modelViewMatrix));
  NSLog(@"GameView render effect: %@", NSStringFromGLKMatrix4(self.effect.transform.modelviewMatrix));
  
  [self.grid render:self.effect];
}

- (void)updateProjection:(CGSize)size  {
  GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-size.width / 2, size.width / 2, -size.height / 2, size.height / 2, 0.0f, 1000.0f);
  self.effect.transform.projectionMatrix = projectionMatrix;
  NSLog(@"updateProjection: %@", NSStringFromCGSize(size));
  [self.effect prepareToDraw];
}

- (void)enableGrid {
  self.grid = [[Grid alloc] init];
  self.grid.parent = self;
}

- (void)disableGrid {
}


@end
