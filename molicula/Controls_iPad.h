//
//  Tutorial.h
//  molicula
//
//  Created by Eric Wolter on 9/11/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Constants.h"

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
  
  GLKVector2 quadrantCross[6];
  GLuint quadrantCrossBuffer;
}

@property id parent;

@property(nonatomic) GLKVector2 position;
@property GLKMatrix4 modelViewMatrix;

- (void)render:(GLKBaseEffect *)effect andRotationInProgress:(BOOL)isRotationInProgress andMirroringInProgress:(BOOL)isMirroringInProgress;
- (void)updateModelViewMatrix;

@end


