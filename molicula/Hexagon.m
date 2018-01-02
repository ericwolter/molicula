//
//  Hexagon.m
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "Hexagon.h"
#import "ColorTheme.h"

@implementation Hexagon

static GLuint vertexBuffer;

@synthesize position = _position;

- (void)setPosition:(GLKVector2)position {
  _position = position;
  
  self.modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(position.x, position.y, 0.0f), self.modelMatrix);
}

- (void)render:(GLKBaseEffect *)effect {
  effect.transform.modelviewMatrix = [self calculateModelViewMatrix];
  [effect prepareToDraw]; CHECK_GL_ERROR();
  
  glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer); CHECK_GL_ERROR();
  glEnableVertexAttribArray(GLKVertexAttribPosition); CHECK_GL_ERROR();
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0); CHECK_GL_ERROR();
  glDrawArrays(GL_TRIANGLE_FAN, 0, CIRCLE_RESOLUTION); CHECK_GL_ERROR();
  glDisableVertexAttribArray(GLKVertexAttribPosition); CHECK_GL_ERROR();
  glBindBuffer(GL_ARRAY_BUFFER, 0);CHECK_GL_ERROR();
}

- (id)init {
  if (self = [super init]) {
    
    if (!vertexBuffer) {
      GLKVector2 vertices[CIRCLE_RESOLUTION];
      for (int i = 0; i < CIRCLE_RESOLUTION; i++) {
        float theta = ((float) i / CIRCLE_RESOLUTION) * 2 * M_PI;
        
        GLKVector2 circlePoint = GLKVector2Make(cos(theta) * 1.0f, sin(theta) * 1.0f);
        vertices[i] = circlePoint;
      }
      glGenBuffers(1, &vertexBuffer); CHECK_GL_ERROR();
      glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer); CHECK_GL_ERROR();
      glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW); CHECK_GL_ERROR();
      glBindBuffer(GL_ARRAY_BUFFER, 0); CHECK_GL_ERROR();
    }
    
    self.objectMatrix = GLKMatrix4MakeScale(CIRCLE_SCALE, CIRCLE_SCALE, 1.0f);
    self.modelMatrix = GLKMatrix4Identity;
  }
  
  return self;
}

@end
