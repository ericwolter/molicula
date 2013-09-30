//
//  GameViewController_iPhone.m
//  molicula
//
//  Created by Eric Wolter on 9/30/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "GameViewController_iPhone.h"
#import "Controls_iPhone.h"

@interface GameViewController_iPhone () {
  Controls_iPhone *controls;
  UITouch *controlTouch;
}

@end

@implementation GameViewController_iPhone

- (void)viewDidLoad {
  [super viewDidLoad];
  
  controls = [[Controls_iPhone alloc] init];
}

- (void)render {
  [super render];
  
  if(activeMolecule != nil) {
    [controls render:self.effect around:activeMolecule];
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) __unused event
{
  [super touchesBegan:touches withEvent:event];
  
  if (pointerTouch == nil)
  {
    if (activeMolecule) {
      NSLog(@"controls");
      controlTouch = [touches anyObject];
      CGPoint controlPoint = [self touchPointToGLPoint:[controlTouch locationInView:self.view]];
      if([controls hitTestAt:controlPoint around:activeMolecule] == None) {
        controlTouch = nil;
      } else {
        return;
      }
    }
    
    pointerTouch = [touches anyObject];
    CGPoint point = [self touchPointToGLPoint:[pointerTouch locationInView:self.view]];
    
    // check if any molecule was selected
    for (int moleculeIndex = molecules.count - 1; moleculeIndex >= 0; moleculeIndex--)
    {
      Molecule *m = [molecules objectAtIndex:moleculeIndex];
      if ([m hitTest:point])
      {
        activeMolecule = m;
        activeMolecule.position = GLKVector2Make(point.x, point.y);
        [molecules removeObjectAtIndex:moleculeIndex];
        [molecules addObject:m];
        [m unsnap];
        for(Molecule *molecule in molecules) {
          if(molecule!=activeMolecule) {
            [grid snapMolecule:molecule];
          }
        }
        // only a single molecule can be selected -> so stop here
        return;
      }
    }
    
    pointerTouch = nil;
    activeMolecule = nil;
  }
}

- (void) touchesMoved:(NSSet *)__unused touches withEvent:(UIEvent *)event
{
  if (!activeMolecule)
  {
    return;
  }
  
  if (pointerTouch == nil)
  {
    return;
  }
  
  CGPoint point = [self touchPointToGLPoint:[pointerTouch locationInView:self.view]];
  activeMolecule.position = GLKVector2Make(point.x, point.y);
  
  [self enforceScreenBoundsForMolecule:activeMolecule];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *) __unused event
{
  for (UITouch *touch in touches)
  {
    if (pointerTouch == touch)
    {
      [activeMolecule snapOrientation];
      [grid snapMolecule:activeMolecule];
      
      pointerTouch = nil;
      shouldStopUpdating = YES;
      [self checkForSolution];
    }
    if (controlTouch == touch) {
      CGPoint controlPoint = [self touchPointToGLPoint:[controlTouch locationInView:self.view]];
      switch ([controls hitTestAt:controlPoint around:activeMolecule]) {
        case RotateClockwise:
          [activeMolecule rotate:GLKMathDegreesToRadians(60.0f)];
          [activeMolecule snapOrientation];
          [grid snapMolecule:activeMolecule];
          [self checkForSolution];
          break;
        case RotateCounterClockwise:
          [activeMolecule rotate:GLKMathDegreesToRadians(-60.0f)];
          [activeMolecule snapOrientation];
          [grid snapMolecule:activeMolecule];
          [self checkForSolution];
          break;
          
        default:
          break;
      }
      controlTouch = nil;
    }
  }
}

@end
