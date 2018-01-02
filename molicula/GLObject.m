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

@end
