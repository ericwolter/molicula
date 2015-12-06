//
//  Helper.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <GLKit/GLKit.h>

#define RGB( v ) ( ( v ) / 255.0f )

@interface Helper : NSObject

+ (GLKVector2)fakeGLLineFrom:(GLKVector2)from to:(GLKVector2)to withWidth:(float)width;
+ (float)GLKQuaternionInnerProductBetween:(GLKQuaternion)a and:(GLKQuaternion)b;
+ (GLKVector2)keepRect:(CGRect)movingRect outsideOf:(CGRect)fixedRect;
+ (GLKVector2)keepRect:(CGRect)movingRect insideOf:(CGRect)fixedRect;

@end
