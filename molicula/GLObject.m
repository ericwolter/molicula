//
//  GLObject.m
//  molicula
//
//  Created by Eric Wolter on 20.12.17.
//  Copyright © 2017 Eric Wolter. All rights reserved.
//

#import "GLObject.h"

@implementation GLModel

- (GLKMatrix4)calculateModelViewMatrix {
  GLKMatrix4 parentModelViewMatrix = [self.parent modelViewMatrix];
  return GLKMatrix4Multiply(parentModelViewMatrix, GLKMatrix4Multiply(self.modelMatrix, self.objectMatrix));
}

@synthesize invertedModelViewMatrix;
@synthesize modelMatrix;
@synthesize objectMatrix;
@synthesize modelViewMatrix;
@synthesize parent;

- (id)init {
  if (self = [super init]) {
    self.objectMatrix = GLKMatrix4Identity;
    self.modelMatrix = GLKMatrix4Identity;
    self.modelViewMatrix = GLKMatrix4Identity;
    self.invertedModelViewMatrix = GLKMatrix4Invert(self.modelViewMatrix, nil);
  }
  
  return self;
}

@end
