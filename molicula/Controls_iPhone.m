//
//  Controls_iPhone.m
//  molicula
//
//  Created by Eric Wolter on 9/30/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "Controls_iPhone.h"

@implementation Controls_iPhone

- (Transform)hitTestAt:(CGPoint)point around:(Molecule *)molecule {
  CGFloat width = molecule.aabbMax.x - molecule.aabbMin.x;
  CGFloat height = molecule.aabbMax.y - molecule.aabbMin.y;
  GLKVector2 position = GLKVector2Make(molecule.aabbMin.x + width/2.0f, molecule.aabbMin.y + height/2.0f);
  
  GLKVector2 vector = GLKVector2Make(point.x, point.y);
  GLKVector2 leftCenter = GLKVector2Make(position.x - (width/2.0f + CONTROLS_SCALE * 1.1f), position.y);
  GLKVector2 rightCenter = GLKVector2Make(position.x + (width/2.0f + CONTROLS_SCALE * 1.1f), position.y);
  
  if(GLKVector2Distance(leftCenter, vector) <= CONTROLS_SCALE) {
    return RotateClockwise;
  } else if (GLKVector2Distance(rightCenter, vector) <= CONTROLS_SCALE) {
    return RotateCounterClockwise;
  } else {
    return None;
  }
}


- (void)render:(GLKBaseEffect *)effect around:(Molecule *)molecule {
  
  
  GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
  modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, CONTROLS_SCALE, CONTROLS_SCALE, 1.0f);
  CGFloat width = molecule.aabbMax.x - molecule.aabbMin.x;
  CGFloat height = molecule.aabbMax.y - molecule.aabbMin.y;
  GLKVector2 position = GLKVector2Make(molecule.aabbMin.x + width/2.0f, molecule.aabbMin.y + height/2.0f);

  effect.constantColor = GLKVector4Make(effect.constantColor.x, effect.constantColor.y, effect.constantColor.z, 0.7f);
  [effect prepareToDraw];
  
  glEnable(GL_BLEND);
  glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
  
  effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(position.x - (width/2.0f + CONTROLS_SCALE * 1.1f), position.y, 0.0f), modelViewMatrix);
  [effect prepareToDraw];
  
  glBindBuffer(GL_ARRAY_BUFFER, arcBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, ((CONTROLS_RES_ARC)+1)*2);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  
  glBindBuffer(GL_ARRAY_BUFFER, leftArcArrowBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLES, 0, 3);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  
  effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180.0f), 0, 1, 0), modelViewMatrix);
  effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(position.x + (width/2.0f + CONTROLS_SCALE * 1.1f), position.y, 0.0f), effect.transform.modelviewMatrix);
  [effect prepareToDraw];
  
  glBindBuffer(GL_ARRAY_BUFFER, arcBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, ((CONTROLS_RES_ARC)+1)*2);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  
  glBindBuffer(GL_ARRAY_BUFFER, leftArcArrowBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLES, 0, 3);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)initArrow {
  for (int i = 0; i <= CONTROLS_RES_ARC; i++) {
    float theta = ((float) i / CONTROLS_RESOLUTION) * M_TAU;
    
    GLKVector2 circle1Point = GLKVector2Make(cos(theta) * (1.0f - ARROW_THICKNESS), sin(theta) * (1.0f - ARROW_THICKNESS));
    GLKVector2 circle2Point = GLKVector2Make(cos(theta) * 1.0f, sin(theta) * 1.0f);
    arc[2*i] = circle1Point;
    arc[2*i+1] = circle2Point;
  }
  
  glGenBuffers(1, &arcBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, arcBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(arc), arc, GL_STATIC_DRAW);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  
  float tip1theta = (0.0f / CONTROLS_RESOLUTION) * M_TAU;
  
  GLKVector2 unitNormalVector1 = GLKVector2Make(cos(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f), sin(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f));
  
  leftArcArrow[0] = GLKVector2Subtract(unitNormalVector1, GLKVector2MultiplyScalar(unitNormalVector1, ARROW_TIP_WIDTH/2.0f));
  leftArcArrow[1] = GLKVector2Add(unitNormalVector1, GLKVector2MultiplyScalar(unitNormalVector1, ARROW_TIP_WIDTH/2.0f));
  leftArcArrow[2] = GLKVector2Add(unitNormalVector1, GLKVector2MultiplyScalar(GLKVector2Make(sin(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f), -cos(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f)), ARROW_TIP_HEIGHT));
  
  glGenBuffers(1, &leftArcArrowBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, leftArcArrowBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(leftArcArrow), leftArcArrow, GL_STATIC_DRAW);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (id)init {
  if (self = [super init]) {
    
    [self initArrow];
  }
  
  return self;
}

@end
