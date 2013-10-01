//
//  Tutorial.m
//  molicula
//
//  Created by Eric Wolter on 9/11/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "Controls.h"
#import "ColorTheme.h"

@implementation Controls

@synthesize modelViewMatrix, parent;
@synthesize position = _position;

- (void)setPosition:(GLKVector2)position {
  _position = position;
  
  [self updateModelViewMatrix];
}

- (void)renderRotation {
  glBindBuffer(GL_ARRAY_BUFFER, rightArcBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, ((TUTORIAL_RESOLUTION/TUTORIAL_ARC_RATIO)+1)*2);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  
  glBindBuffer(GL_ARRAY_BUFFER, rightArcArrowBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLES, 0, 6);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  
  glBindBuffer(GL_ARRAY_BUFFER, leftArcBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, ((TUTORIAL_RESOLUTION/TUTORIAL_ARC_RATIO)+1)*2);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  
  glBindBuffer(GL_ARRAY_BUFFER, leftArcArrowBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLES, 0, 6);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)renderMirroring {
  glBindBuffer(GL_ARRAY_BUFFER, topBarBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLES, 0, 6);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  
  glBindBuffer(GL_ARRAY_BUFFER, topBarArrowBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLES, 0, 6);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  
  glBindBuffer(GL_ARRAY_BUFFER, bottomBarBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLES, 0, 6);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  
  glBindBuffer(GL_ARRAY_BUFFER, bottomBarArrowBuffer);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLES, 0, 6);
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)render:(GLKBaseEffect *)effect andRotationInProgress:(BOOL)isRotationInProgress andMirroringInProgress:(BOOL)isMirroringInProgress {
  effect.constantColor = GLKVector4Make(effect.constantColor.x, effect.constantColor.y, effect.constantColor.z, 0.5f);
  effect.transform.modelviewMatrix = self.modelViewMatrix;
  [effect prepareToDraw];
  
  glEnable(GL_BLEND);
  glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

  if (isRotationInProgress && !isMirroringInProgress) {
    [self renderRotation];
  } else if (!isRotationInProgress && isMirroringInProgress){
    [self renderMirroring];
  } else {
    [self renderRotation];
    [self renderMirroring];
  }
}

- (void)updateModelViewMatrix {
  self.modelViewMatrix = GLKMatrix4Identity;
  self.modelViewMatrix = GLKMatrix4Scale(self.modelViewMatrix, TUTORIAL_SCALE, TUTORIAL_SCALE, 1.0f);
  self.modelViewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(self.position.x, self.position.y, 0), self.modelViewMatrix);
}


- (void)initRightArrow {
    for (int i = 0; i <= TUTORIAL_RESOLUTION/TUTORIAL_ARC_RATIO; i++) {
        float theta = ((float) i / TUTORIAL_RESOLUTION) * M_TAU;
        theta += (-1.0f/(TUTORIAL_ARC_RATIO*2.0f)) * M_TAU;
        
        GLKVector2 circle1Point = GLKVector2Make(cos(theta) * (1.0f - ARROW_THICKNESS), sin(theta) * (1.0f - ARROW_THICKNESS));
        GLKVector2 circle2Point = GLKVector2Make(cos(theta) * 1.0f, sin(theta) * 1.0f);
        rightArc[2*i] = circle1Point;
        rightArc[2*i+1] = circle2Point;
    }
    
    glGenBuffers(1, &rightArcBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, rightArcBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(rightArc), rightArc, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    float tip1theta = (0.0f / TUTORIAL_RESOLUTION) * M_TAU + (-1.0f/(TUTORIAL_ARC_RATIO*2.0f)) * M_TAU;
    float tip2theta = (1.0f/TUTORIAL_ARC_RATIO) * M_TAU + (-1.0f/(TUTORIAL_ARC_RATIO*2.0f)) * M_TAU;
    
    GLKVector2 unitNormalVector1 = GLKVector2Make(cos(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f), sin(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f));
    GLKVector2 unitNormalVector2 = GLKVector2Make(cos(tip2theta) * (1.0f-ARROW_THICKNESS/2.0f), sin(tip2theta) * (1.0f-ARROW_THICKNESS/2.0f));
    
    rightArcArrow[0] = GLKVector2Subtract(unitNormalVector1, GLKVector2MultiplyScalar(unitNormalVector1, ARROW_TIP_WIDTH/2.0f));
    rightArcArrow[1] = GLKVector2Add(unitNormalVector1, GLKVector2MultiplyScalar(unitNormalVector1, ARROW_TIP_WIDTH/2.0f));
    rightArcArrow[2] = GLKVector2Add(unitNormalVector1, GLKVector2MultiplyScalar(GLKVector2Make(sin(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f), -cos(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f)), ARROW_TIP_HEIGHT));
    rightArcArrow[3] = GLKVector2Subtract(unitNormalVector2, GLKVector2MultiplyScalar(unitNormalVector2, ARROW_TIP_WIDTH/2.0f));
    rightArcArrow[4] = GLKVector2Add(unitNormalVector2, GLKVector2MultiplyScalar(unitNormalVector2, ARROW_TIP_WIDTH/2.0f));
    rightArcArrow[5] = GLKVector2Add(unitNormalVector2, GLKVector2MultiplyScalar(GLKVector2Make(-sin(tip2theta) * (1.0f-ARROW_THICKNESS/2.0f), cos(tip2theta) * (1.0f-ARROW_THICKNESS/2.0f)), ARROW_TIP_HEIGHT));
    
    glGenBuffers(1, &rightArcArrowBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, rightArcArrowBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(rightArcArrow), rightArcArrow, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)initLeftArrow {
    for (int i = 0; i <= TUTORIAL_RESOLUTION/TUTORIAL_ARC_RATIO; i++) {
        float theta = ((float) i / TUTORIAL_RESOLUTION) * M_TAU;
        theta += ((-1.0/2.0f) + (-1.0f/(TUTORIAL_ARC_RATIO*2.0f))) * M_TAU;
        
        GLKVector2 circle1Point = GLKVector2Make(cos(theta) * (1.0f - ARROW_THICKNESS), sin(theta) * (1.0f - ARROW_THICKNESS));
        GLKVector2 circle2Point = GLKVector2Make(cos(theta) * 1.0f, sin(theta) * 1.0f);
        leftArc[2*i] = circle1Point;
        leftArc[2*i+1] = circle2Point;
    }
    
    glGenBuffers(1, &leftArcBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, leftArcBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(leftArc), leftArc, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    float tip1theta = (0.0f / TUTORIAL_RESOLUTION) * M_TAU + ((-1.0/2.0f) + (-1.0f/(TUTORIAL_ARC_RATIO*2.0f))) * M_TAU;
    float tip2theta = (1.0f/TUTORIAL_ARC_RATIO) * M_TAU + ((-1.0/2.0f) + (-1.0f/(TUTORIAL_ARC_RATIO*2.0f))) * M_TAU;
    
    GLKVector2 unitNormalVector1 = GLKVector2Make(cos(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f), sin(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f));
    GLKVector2 unitNormalVector2 = GLKVector2Make(cos(tip2theta) * (1.0f-ARROW_THICKNESS/2.0f), sin(tip2theta) * (1.0f-ARROW_THICKNESS/2.0f));
    
    leftArcArrow[0] = GLKVector2Subtract(unitNormalVector1, GLKVector2MultiplyScalar(unitNormalVector1, ARROW_TIP_WIDTH/2.0f));
    leftArcArrow[1] = GLKVector2Add(unitNormalVector1, GLKVector2MultiplyScalar(unitNormalVector1, ARROW_TIP_WIDTH/2.0f));
    leftArcArrow[2] = GLKVector2Add(unitNormalVector1, GLKVector2MultiplyScalar(GLKVector2Make(sin(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f), -cos(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f)), ARROW_TIP_HEIGHT));
    leftArcArrow[3] = GLKVector2Subtract(unitNormalVector2, GLKVector2MultiplyScalar(unitNormalVector2, ARROW_TIP_WIDTH/2.0f));
    leftArcArrow[4] = GLKVector2Add(unitNormalVector2, GLKVector2MultiplyScalar(unitNormalVector2, ARROW_TIP_WIDTH/2.0f));
    leftArcArrow[5] = GLKVector2Add(unitNormalVector2, GLKVector2MultiplyScalar(GLKVector2Make(-sin(tip2theta) * (1.0f-ARROW_THICKNESS/2.0f), cos(tip2theta) * (1.0f-ARROW_THICKNESS/2.0f)), ARROW_TIP_HEIGHT));
    
    glGenBuffers(1, &leftArcArrowBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, leftArcArrowBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(leftArcArrow), leftArcArrow, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)initTopBar {
    float tip1theta = M_TAU / 4.0f + (1.0f/((TUTORIAL_ARC_RATIO+1)*2.0f)) * M_TAU;
    float tip2theta = M_TAU / 4.0f - (1.0f/((TUTORIAL_ARC_RATIO+1)*2.0f)) * M_TAU;
    
    GLKVector2 unitNormalVector1 = GLKVector2Make(cos(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f), sin(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f));
    GLKVector2 unitNormalVector2 = GLKVector2Make(cos(tip2theta) * (1.0f-ARROW_THICKNESS/2.0f), sin(tip2theta) * (1.0f-ARROW_THICKNESS/2.0f));
    
    topBar[0] = GLKVector2Subtract(unitNormalVector1, GLKVector2Make(0.0f, ARROW_THICKNESS/2.0f));
    topBar[1] = GLKVector2Add(unitNormalVector1, GLKVector2Make(0.0f, ARROW_THICKNESS/2.0f));
    topBar[2] = GLKVector2Add(unitNormalVector2, GLKVector2Make(0.0f, ARROW_THICKNESS/2.0f));
    topBar[3] = GLKVector2Subtract(unitNormalVector1, GLKVector2Make(0.0f, ARROW_THICKNESS/2.0f));
    topBar[4] = GLKVector2Add(unitNormalVector2, GLKVector2Make(0.0f, ARROW_THICKNESS/2.0f));
    topBar[5] = GLKVector2Subtract(unitNormalVector2, GLKVector2Make(0.0f, ARROW_THICKNESS/2.0f));
    
    glGenBuffers(1, &topBarBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, topBarBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(topBar), topBar, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    topBarArrow[0] = GLKVector2Subtract(unitNormalVector1, GLKVector2Make(0.0f, ARROW_TIP_WIDTH/2.0f));
    topBarArrow[1] = GLKVector2Add(unitNormalVector1, GLKVector2Make(0.0f, ARROW_TIP_WIDTH/2.0f));
    topBarArrow[2] = GLKVector2Subtract(unitNormalVector1, GLKVector2Make(ARROW_TIP_HEIGHT, 0.0f));
    topBarArrow[3] = GLKVector2Add(unitNormalVector2, GLKVector2Make(0.0f, ARROW_TIP_WIDTH/2.0f));
    topBarArrow[4] = GLKVector2Subtract(unitNormalVector2, GLKVector2Make(0.0f, ARROW_TIP_WIDTH/2.0f));
    topBarArrow[5] = GLKVector2Add(unitNormalVector2, GLKVector2Make(ARROW_TIP_HEIGHT, 0.0f));
    
    glGenBuffers(1, &topBarArrowBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, topBarArrowBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(topBarArrow), topBarArrow, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (id)init {
  if (self = [super init]) {
    
    [self initRightArrow];
    [self initLeftArrow];
    
    [self initTopBar];
    
    float tip1theta = 3.0f * M_TAU / 4.0f - (1.0f/((TUTORIAL_ARC_RATIO+1)*2.0f)) * M_TAU;
    float tip2theta = 3.0f * M_TAU / 4.0f + (1.0f/((TUTORIAL_ARC_RATIO+1)*2.0f)) * M_TAU;
    
    GLKVector2 unitNormalVector1 = GLKVector2Make(cos(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f), sin(tip1theta) * (1.0f-ARROW_THICKNESS/2.0f));
    GLKVector2 unitNormalVector2 = GLKVector2Make(cos(tip2theta) * (1.0f-ARROW_THICKNESS/2.0f), sin(tip2theta) * (1.0f-ARROW_THICKNESS/2.0f));
    
    bottomBar[0] = GLKVector2Subtract(unitNormalVector1, GLKVector2Make(0.0f, ARROW_THICKNESS/2.0f));
    bottomBar[1] = GLKVector2Add(unitNormalVector1, GLKVector2Make(0.0f, ARROW_THICKNESS/2.0f));
    bottomBar[2] = GLKVector2Add(unitNormalVector2, GLKVector2Make(0.0f, ARROW_THICKNESS/2.0f));
    bottomBar[3] = GLKVector2Subtract(unitNormalVector1, GLKVector2Make(0.0f, ARROW_THICKNESS/2.0f));
    bottomBar[4] = GLKVector2Add(unitNormalVector2, GLKVector2Make(0.0f, ARROW_THICKNESS/2.0f));
    bottomBar[5] = GLKVector2Subtract(unitNormalVector2, GLKVector2Make(0.0f, ARROW_THICKNESS/2.0f));
    
    glGenBuffers(1, &bottomBarBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, bottomBarBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(bottomBar), bottomBar, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    bottomBarArrow[0] = GLKVector2Subtract(unitNormalVector1, GLKVector2Make(0.0f, ARROW_TIP_WIDTH/2.0f));
    bottomBarArrow[1] = GLKVector2Add(unitNormalVector1, GLKVector2Make(0.0f, ARROW_TIP_WIDTH/2.0f));
    bottomBarArrow[2] = GLKVector2Subtract(unitNormalVector1, GLKVector2Make(ARROW_TIP_HEIGHT, 0.0f));
    bottomBarArrow[3] = GLKVector2Add(unitNormalVector2, GLKVector2Make(0.0f, ARROW_TIP_WIDTH/2.0f));
    bottomBarArrow[4] = GLKVector2Subtract(unitNormalVector2, GLKVector2Make(0.0f, ARROW_TIP_WIDTH/2.0f));
    bottomBarArrow[5] = GLKVector2Add(unitNormalVector2, GLKVector2Make(ARROW_TIP_HEIGHT, 0.0f));
    
    glGenBuffers(1, &bottomBarArrowBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, bottomBarArrowBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(bottomBarArrow), bottomBarArrow, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    
//    float size = ARROW_THICKNESS / sqrtf(2.0f);
//    quadrantCross[0] = GLKVector2Make(0.0f, -size);
//    quadrantCross[1] = GLKVector2Make(0.0f, +size);
//    quadrantCross[2] = GLKVector2Make(-size, 0.0f);
//    quadrantCross[3] = GLKVector2Make(0.0f, -size);
//    quadrantCross[4] = GLKVector2Make(+size, 0.0f);
//    quadrantCross[5] = GLKVector2Make(0.0f, +size);
//    
//    glGenBuffers(1, &quadrantCrossBuffer);
//    glBindBuffer(GL_ARRAY_BUFFER, quadrantCrossBuffer);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(quadrantCross), quadrantCross, GL_STATIC_DRAW);
//    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    [self updateModelViewMatrix];
  }
  
  return self;
}

@end