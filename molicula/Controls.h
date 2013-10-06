//
//  Tutorial.h
//  molicula
//
//  Created by Eric Wolter on 9/11/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Molecule.h"
#import "Constants.h"

typedef enum {
  None,
  Rotate,
  Mirror
} ControlTransform;

/**
 * Enum type used to describe the quadrant the transform touch is relative
 * to the pointer touch
 */
typedef enum {
  QuadrantUndefined,
  QuadrantTop,
  QuadrantBottom,
  QuadrantLeft,
  QuadrantRight
} Quadrant;

/**
 * Enum type used to describe on which side a point lies relative to a line.
 */
typedef enum {
  PointOnLine,
  PointOnLeftSide,
  PointOnRightSide
} LinePosition;

@interface Controls : NSObject {
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
- (ControlTransform)hitTestAt:(CGPoint)point around:(Molecule *)molecule;
- (Quadrant)determineTouchQuadrantFor:(CGPoint)transformPoint RelativeTo:(CGPoint)pointerPoint;
- (LinePosition)determineOnWhichSideOfLine:(CGPoint*)line LiesPoint:(CGPoint)point;

@end

