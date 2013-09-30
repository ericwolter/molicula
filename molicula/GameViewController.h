//
//  ViewController.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "Molecule.h"

@interface GameViewController : GLKViewController <UIGestureRecognizerDelegate> {
  BOOL isRotationInProgress;
  BOOL isMirroringInProgress;

  UITouch *pointerTouch;
  UITouch *transformTouch;
  
  /**
   * Whenever the user picks up a molecule this holds a pointer to it.
   */
  Molecule *activeMolecule;
}

@property(strong, nonatomic) GLKBaseEffect *effect;

- (void)render;

- (CGPoint) touchPointToGLPoint:(CGPoint)point;

@end