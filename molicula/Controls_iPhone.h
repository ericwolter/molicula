//
//  Controls_iPhone.h
//  molicula
//
//  Created by Eric Wolter on 9/30/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Molecule.h"

#define M_TAU                     (M_PI * 2.0f)

#define CONTROLS_RESOLUTION       (64)
#define CONTROLS_ARC_RATIO        (4.0f/3.0f)
#define CONTROLS_RES_ARC          (48) // CONTROLS_RESOLUTION / CONTROLS_ARC_RATIO
#define CONTROLS_SCALE            (24)
#define ARROW_THICKNESS           (0.4f)
#define ARROW_TIP_HEIGHT          (0.5f)
#define ARROW_TIP_WIDTH           (0.8f)
#define BAR_OFFSET_Y              (0.0f)

typedef enum {
  None,
  Mirror,
  RotateClockwise,
  RotateCounterClockwise
} Transform;

@interface Controls_iPhone : NSObject {
  GLKVector2 arc[((CONTROLS_RES_ARC)+1)*2];
  GLuint arcBuffer;
  
  GLKVector2 leftArcArrow[3];
  GLuint leftArcArrowBuffer;
}

- (void)render:(GLKBaseEffect *)effect around:(Molecule *)molecule;

- (Transform)hitTestAt:(CGPoint)point around:(Molecule *)molecule;

@end
