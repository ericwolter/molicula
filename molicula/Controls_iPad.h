//
//  Tutorial.h
//  molicula
//
//  Created by Eric Wolter on 9/11/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#define M_TAU                     (M_PI * 2.0f)

#define TUTORIAL_RESOLUTION       (65)
#define TUTORIAL_ARC_RATIO        (5)
#define TUTORIAL_SCALE            (128)
#define ARROW_THICKNESS           (0.1f)
#define ARROW_TIP_HEIGHT          (0.1f)
#define ARROW_TIP_WIDTH           (0.2f)
#define BAR_OFFSET_Y              (0.0f)

@interface Controls_iPad : NSObject {
  GLKVector2 rightArc[((TUTORIAL_RESOLUTION/TUTORIAL_ARC_RATIO)+1)*2];
  GLuint rightArcBuffer;
  
  GLKVector2 rightArcArrow[6];
  GLuint rightArcArrowBuffer;
  
  GLKVector2 leftArc[((TUTORIAL_RESOLUTION/TUTORIAL_ARC_RATIO)+1)*2];
  GLuint leftArcBuffer;
  
  GLKVector2 leftArcArrow[6];
  GLuint leftArcArrowBuffer;
  
  GLKVector2 topBar[6];
  GLuint topBarBuffer;
  
  GLKVector2 topBarArrow[6];
  GLuint topBarArrowBuffer;
  
  GLKVector2 bottomBar[6];
  GLuint bottomBarBuffer;
  
  GLKVector2 bottomBarArrow[6];
  GLuint bottomBarArrowBuffer;
}

@property id parent;

@property(nonatomic) GLKVector2 position;
@property GLKMatrix4 modelViewMatrix;

- (void)render:(GLKBaseEffect *)effect andRotationInProgress:(BOOL)isRotationInProgress andMirroringInProgress:(BOOL)isMirroringInProgress;
- (void)updateModelViewMatrix;

@end


