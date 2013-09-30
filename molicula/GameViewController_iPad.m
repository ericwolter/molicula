//
//  GameViewController_iPad.m
//  molicula
//
//  Created by Eric Wolter on 9/30/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "GameViewController_iPad.h"
#import "Controls_iPad.h"

@interface GameViewController_iPad () {
  Controls_iPad *controls;
  
  UITouch *transformTouch;
  
  BOOL isRotationInProgress;
  BOOL isMirroringInProgress;
  
  CGFloat transformRotationAngle;
  CGFloat transformMirroringOffset;
}

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

- (Quadrant)determineTouchQuadrantFor:(CGPoint)transformPoint RelativeTo:(CGPoint)pointerPoint;
- (LinePosition)determineOnWhichSideOfLine:(CGPoint*)line LiesPoint:(CGPoint)point;

@end

@implementation GameViewController_iPad

- (void)viewDidLoad {
  [super viewDidLoad];
  
  controls = [[Controls_iPad alloc] init];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  transformTouch = nil;
}

- (void)applicationWillResignActive {
  [super applicationWillResignActive];
  transformTouch = nil;
}

- (void)render {
  [super render];
  
  if(pointerTouch != nil) {
    CGPoint point = [self touchPointToGLPoint:[pointerTouch locationInView:self.view]];
    [controls setPosition:GLKVector2Make(point.x, point.y)];
    self.effect.constantColor = activeMolecule.color;
    [controls render:self.effect andRotationInProgress:isRotationInProgress andMirroringInProgress:isMirroringInProgress];
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) __unused event
{
  [super touchesBegan:touches withEvent:event];
  
  if (pointerTouch == nil)
  {
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
  } else if (transformTouch == nil) {
    transformTouch = [touches anyObject];
    
    CGPoint pointerLocation = [pointerTouch locationInView:self.view];
    CGPoint transformLocation = [transformTouch locationInView:self.view];
    transformRotationAngle = atan2(transformLocation.y - pointerLocation.y, transformLocation.x - pointerLocation.x);
    transformMirroringOffset = transformLocation.x;
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
  
  if (transformTouch != nil)
  {
    if (!isRotationInProgress && !isMirroringInProgress) {
      CGPoint modifierPoint = [self touchPointToGLPoint:[transformTouch locationInView:self.view]];
      
      // determine quadrant
      Quadrant quadrant = [self determineTouchQuadrantFor:modifierPoint RelativeTo:point];
      switch(quadrant) {
        case QuadrantLeft:
        case QuadrantRight:
          isRotationInProgress = true;
          isMirroringInProgress = false;
          break;
        case QuadrantTop:
        case QuadrantBottom:
          isRotationInProgress = false;
          isMirroringInProgress = true;
          break;
        default:
          break;
      }
    }
    
    CGPoint pointerLocation = [pointerTouch locationInView:self.view];
    CGPoint transformLocation = [transformTouch locationInView:self.view];
    
    if (isRotationInProgress) {
      CGFloat newTransformRotationAngle = atan2(transformLocation.y - pointerLocation.y, transformLocation.x - pointerLocation.x);
      [activeMolecule rotate:newTransformRotationAngle-transformRotationAngle];
      transformRotationAngle = newTransformRotationAngle;
    } else if (isMirroringInProgress) {
      CGFloat newTransformMirroringOffset = transformLocation.x;
      [activeMolecule mirror:GLKMathDegreesToRadians(newTransformMirroringOffset - transformMirroringOffset) * 0.8f];
      transformMirroringOffset = newTransformMirroringOffset;
    }
    
  }
  
  [self enforceScreenBoundsForMolecule:activeMolecule];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *) __unused event
{
  for (UITouch *touch in touches)
  {
    if (pointerTouch == touch)
    {
      [activeMolecule snapOrientation];
      isRotationInProgress = false;
      isMirroringInProgress = false;
      
      pointerTouch = nil;
      transformTouch = nil;
      [grid snapMolecule:activeMolecule];
      activeMolecule = nil;
      
      shouldStopUpdating = YES;
      [self checkForSolution];
    }
    if (transformTouch == touch)
    {
      transformTouch = nil;
      
      [activeMolecule snapOrientation];
      isRotationInProgress = false;
      isMirroringInProgress = false;
    }
  }
}

- (Quadrant)determineTouchQuadrantFor:(CGPoint)transformPoint RelativeTo:(CGPoint)pointerPoint {
  
  CGPoint ascendingDiagonal[2] = { pointerPoint, CGPointMake(pointerPoint.x + 1, pointerPoint.y + 1) };
  CGPoint descendingDiagonal[2] = { pointerPoint, CGPointMake(pointerPoint.x + 1, pointerPoint.y - 1) };
  
  LinePosition ascendingSide = [self determineOnWhichSideOfLine:ascendingDiagonal LiesPoint:transformPoint];
  LinePosition descendingSide = [self determineOnWhichSideOfLine:descendingDiagonal LiesPoint:transformPoint];
  
  if (ascendingSide == PointOnRightSide && descendingSide == PointOnRightSide) {
    return QuadrantTop;
  } else if (ascendingSide == PointOnRightSide && descendingSide == PointOnLeftSide) {
    return QuadrantLeft;
  } else if (ascendingSide == PointOnLeftSide && descendingSide == PointOnRightSide) {
    return QuadrantRight;
  } else if (ascendingSide == PointOnLeftSide && descendingSide == PointOnLeftSide) {
    return QuadrantBottom;
  } else {
    return QuadrantUndefined;
  }
}

- (LinePosition)determineOnWhichSideOfLine:(CGPoint*)line LiesPoint:(CGPoint)point {
  // the pseudo distance will be zero if the point on the line
  // otherwise it will be positive for the 'right' side and negative for the
  // 'left' side
  float pseudoDistance = (line[1].x - line[0].x) * (point.y - line[0].y) - (line[1].y - line[0].y) * (point.x - line[0].x);
  
  int side = (pseudoDistance > 0) - (pseudoDistance < 0);
  
  if (side < 0) {
    return PointOnLeftSide;
  } else if (side > 0) {
    return PointOnRightSide;
  } else {
    return PointOnLine;
  }
}


@end
