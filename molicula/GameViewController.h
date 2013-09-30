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
  UITouch *pointerTouch;
  
  /**
   * Holds the main playing grid.
   */
  Grid *grid;
  
  /**
   * Whenever the user picks up a molecule this holds a pointer to it.
   */
  Molecule *activeMolecule;
  
  /**
   * Contains all molecules in the current game.
   */
  NSMutableArray *molecules;
  
  BOOL shouldStopUpdating;
}

@property(strong, nonatomic) GLKBaseEffect *effect;

- (void)applicationWillResignActive;

- (void)render;

- (CGPoint) touchPointToGLPoint:(CGPoint)point;

- (void)enforceScreenBoundsForMolecule:(Molecule *)molecule;

- (void)checkForSolution;

@end