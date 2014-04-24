//
//  Hexagon.m
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "Hexagon.h"
#import "ColorTheme.h"

static GLuint vertexBuffer;

@implementation Hexagon

@synthesize modelViewMatrix, parent;
@synthesize position = _position;

//- (GLKVector2 *) vertices
//{
//    if (vertexData == nil)
//    {
//        vertexData = [NSMutableData dataWithLength:sizeof(GLKVector2) * CIRCLE_RESOLUTION];
//    }
//    return [vertexData mutableBytes];
//}
//
//- (GLKVector4 *) vertexColors
//{
//    if (vertexColorData == nil)
//    {
//        vertexColorData = [NSMutableData dataWithLength:sizeof(GLKVector4) * CIRCLE_RESOLUTION];
//    }
//    return [vertexColorData mutableBytes];
//}

- (void)setPosition:(GLKVector2)position {
  _position = position;
  
  self.modelViewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(position.x, position.y, 0.0f), self.modelViewMatrix);
}

- (void)render:(GLKBaseEffect *)effect {
  GLKMatrix4 parentModelViewMatrix = [self.parent modelViewMatrix];
  effect.transform.modelviewMatrix = GLKMatrix4Multiply(parentModelViewMatrix, self.modelViewMatrix);
  [effect prepareToDraw];
  
  glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLE_FAN, 0, CIRCLE_RESOLUTION);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (id)init {
  if (self = [super init]) {
    GLKVector2 vertices[CIRCLE_RESOLUTION];
    for (int i = 0; i < CIRCLE_RESOLUTION; i++) {
      float theta = ((float) i / CIRCLE_RESOLUTION) * 2 * M_PI;
      
      GLKVector2 circlePoint = GLKVector2Make(cos(theta) * 1.0f, sin(theta) * 1.0f);
      vertices[i] = circlePoint;
    }
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    self.modelViewMatrix = GLKMatrix4Identity;
    self.modelViewMatrix = GLKMatrix4Scale(self.modelViewMatrix, CIRCLE_SCALE, CIRCLE_SCALE, 1.0f);
  }
  
  return self;
}

@end
