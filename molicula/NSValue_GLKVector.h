//
//  NSValue_GLKVector.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface NSValue (GLKVector)
+ (NSValue *)valueWithGLKVector2:(GLKVector2)vector;
- (GLKVector2)GLKVector2Value;
@end

@implementation NSValue (GLKVector)
+ (NSValue *)valueWithGLKVector2:(GLKVector2)vector {
  return [NSValue valueWithCGPoint:CGPointMake(vector.x, vector.y)];
}

- (GLKVector2)GLKVector2Value {
  CGPoint p = [self CGPointValue];
  return GLKVector2Make(p.x, p.y);
}
@end
