//
//  Helper.m
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (GLKVector2)fakeGLLineFrom:(GLKVector2)from to:(GLKVector2)to withWidth:(float)width {
  GLKVector2 direction = GLKVector2Subtract(from, to);
  GLKVector2 perpendicular = GLKVector2Make(direction.y, -direction.x);
  perpendicular = GLKVector2Normalize(perpendicular);
  perpendicular = GLKVector2MultiplyScalar(perpendicular, width);
  
  return perpendicular;
}

@end
