//
//  Helper.m
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (GLKVector4)makeVectorFromUIColor:(UIColor*)color {
  const CGFloat *colors = CGColorGetComponents( color.CGColor );
  return GLKVector4Make(colors[0], colors[1], colors[2], colors[3]);
}
+ (GLKVector2)fakeGLLineFrom:(GLKVector2)from to:(GLKVector2)to withWidth:(float)width {
  GLKVector2 direction = GLKVector2Subtract(from, to);
  GLKVector2 perpendicular = GLKVector2Make(direction.y, -direction.x);
  perpendicular = GLKVector2Normalize(perpendicular);
  perpendicular = GLKVector2MultiplyScalar(perpendicular, width);
  
  return perpendicular;
}

+ (float)GLKQuaternionInnerProductBetween:(GLKQuaternion)a and:(GLKQuaternion)b {
  return
    a.x * b.x +
    a.y * b.y +
    a.z * b.z +
    a.w * b.w;
}


+ (GLKVector2)keepRect:(CGRect)movingRect outsideOf:(CGRect)fixedRect {
  bool doOverlapX = CGRectGetMaxX(movingRect) > CGRectGetMinX(fixedRect) && CGRectGetMinX(movingRect) < CGRectGetMaxX(fixedRect);
  bool doOverlapY = CGRectGetMaxY(movingRect) > CGRectGetMinY(fixedRect) && CGRectGetMinY(movingRect) < CGRectGetMaxY(fixedRect);
  
  GLKVector2 resultVector = GLKVector2Make(0, 0);
  if(doOverlapX && doOverlapY) {
    float leftOut = CGRectGetMinX(fixedRect) - CGRectGetMaxX(movingRect);
    float rightOut = CGRectGetMaxX(fixedRect) - CGRectGetMinX(movingRect);
    float downOut = CGRectGetMinY(fixedRect) - CGRectGetMaxY(movingRect);
    float upOut = CGRectGetMaxY(fixedRect) - CGRectGetMinY(movingRect);
    
    float horizontalOut = fminf(fabsf(leftOut), fabsf(rightOut));
    float verticalOut = fminf(fabsf(downOut), fabsf(upOut));
    
    if (horizontalOut < verticalOut) {
      resultVector.x = fabsf(leftOut) < fabsf(rightOut) ? leftOut : rightOut;
    } else {
      resultVector.y = upOut;
    }
  }
  return resultVector;
//
//  float x = fmaxf(movingRect.origin.x, fixedRect.origin.x);
//  float num1 = fminf(movingRect.origin.x + movingRect.size.width, fixedRect.origin.x + fixedRect.size.width);
//  float y = fmaxf(movingRect.origin.y, fixedRect.origin.y);
//  float num2 = fminf(movingRect.origin.y + movingRect.size.height, fixedRect.origin.y + fixedRect.size.height);
//  if(num1 >= x && num2 >= y) {
//    MLog("x:%f,num1:%f,y:%f,num2:%f",x,num1,y,num2);
//  }
}
+ (GLKVector2)keepRect:(CGRect)movingRect insideOf:(CGRect)fixedRect {
  GLKVector2 resultVector = GLKVector2Make(0, 0);
  
  float leftOut, rightOut, downOut, upOut;
  leftOut = CGRectGetMinX(movingRect) - CGRectGetMinX(fixedRect);
  rightOut = CGRectGetMaxX(movingRect) - CGRectGetMaxX(fixedRect);
  if (leftOut < 0)
  {
    resultVector.x -= leftOut;
  }
  if (rightOut > 0)
  {
    resultVector.x -= rightOut;
  }
  downOut = CGRectGetMinY(movingRect) - CGRectGetMinY(fixedRect);
  upOut = CGRectGetMaxY(movingRect) - CGRectGetMaxY(fixedRect);
  if (downOut < 0)
  {
    resultVector.y -= downOut;
  }
  if (upOut > 0)
  {
    resultVector.y -= upOut;
  }
  
  return resultVector;
}

@end
