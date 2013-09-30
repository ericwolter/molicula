//
//  ViewController.m
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "GameViewController.h"
#import "MoleculeFactory.h"
#import "Molecule.h"
#import "Grid.h"
#import "ColorTheme.h"
#import "NSValue_GLKVector.h"
#import "Tutorial.h"

@interface GameViewController () {
  /**
   * Holds the main playing grid.
   */
  Grid *grid;
  
  /**
   * Whenever the user picks up a molecule this holds a pointer to it.
   */
  Molecule *activeMolecule;
  
  /**
   * Holds the left over molecule for the finish animation
   */
  Molecule *leftOverMolecule;
  
  Tutorial *tutorial;
  
  /**
   * Contains all molecules in the current game.
   */
  NSMutableArray *molecules;
  
  /**
   * In order to conserve battery the screen is only drawn at the refresh rate
   * if the user is currently moving a molecule.
   */
  BOOL shouldStopUpdating;
  
  BOOL isRotationInProgress;
  BOOL isMirroringInProgress;
  
  CGFloat transformRotationAngle;
  CGFloat transformMirroringOffset;
  
  BOOL finishAnimation;
  int finishTimer;
}

/**
 * The OpenGL context.
 */
@property(strong, nonatomic) EAGLContext *context;
/**
 * The GLKit provided drawing helper.
 */
@property(strong, nonatomic) GLKBaseEffect *effect;

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

- (void)setupGL;
- (void)setupGrid;
- (void)tearDownGL;

- (Quadrant)determineTouchQuadrantFor:(CGPoint)transformPoint RelativeTo:(CGPoint)pointerPoint;
- (LinePosition)determineOnWhichSideOfLine:(CGPoint*)line LiesPoint:(CGPoint)point;

- (void)enforceScreenBoundsForMolecule:(Molecule *)molecule;
- (void)layoutMolecules;
- (void)checkForSolution;

@end

@implementation GameViewController

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self setProjection];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  pointerTouch = nil;
  transformTouch = nil;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  
  if (!self.context) {
    NSLog(@"%@", @"Failed to create ES context");
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:NULL];
  
  GLKView *view = (GLKView *) self.view;
  view.context = self.context;
  view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
  view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
  view.drawableMultisample = GLKViewDrawableMultisample4X;
  view.multipleTouchEnabled = YES;
  view.exclusiveTouch = YES;
  [self setPreferredFramesPerSecond:60];
  
  [self setupGL];
  [self setupGrid];
  tutorial = [[Tutorial alloc] init];
}

- (void)applicationWillResignActive {
  pointerTouch = nil;
  transformTouch = nil;
}

- (void)dealloc {
  [self tearDownGL];
  
  if ([EAGLContext currentContext] == self.context) {
    [EAGLContext setCurrentContext:nil];
  }
  
  self.effect = nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  
  if ([self isViewLoaded] && ([[self view] window] == nil)) {
    self.view = nil;
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
      [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
  }
  
  // Dispose of any resources that can be recreated.
}

- (void)setupGL {
  [EAGLContext setCurrentContext:self.context];
  self.effect = [[GLKBaseEffect alloc] init];
}

- (void)setupGrid {
  
  grid = [[Grid alloc] init];
  
  molecules = [[NSMutableArray alloc] initWithCapacity:7];
  
  //  NSString *solution = @"000oop00bopp0boppybroyyybryww0brww00rrw000";
  //  int row = 0;
  //  int col = 0;
  //  NSMutableDictionary *solutionMolecules = [[NSMutableDictionary alloc] init];
  //  for (uint i = 0; i < [solution length]; ++i) {
  //    NSString *identifier = [solution substringWithRange:NSMakeRange(i, 1)];
  //    row = i / GRID_HEIGHT;
  //    col = i % GRID_HEIGHT - 1;
  //    NSLog(@"%d: (%d,%d): %@", i, row, col, identifier);
  //
  //    if ([identifier isEqualToString:@"0"]) {
  //      continue;
  //    }
  //
  //    if (![solutionMolecules objectForKey:identifier]) {
  //      [solutionMolecules setObject:[NSMutableArray arrayWithCapacity:5] forKey:identifier];
  //    }
  //    NSMutableArray *points = [solutionMolecules objectForKey:identifier];
  //    [points addObject:[NSValue valueWithCGPoint:CGPointMake(row, col)]];
  //
  //  }
  //
  //  for (id key in solutionMolecules) {
  //    CGPoint points[5];
  //    for (uint i=0; i < 5; ++i) {
  //      NSValue *value = [[solutionMolecules objectForKey:key] objectAtIndex:i];
  //      points[i] = [value CGPointValue];
  //    }
  //
  //    PMMolecule *m = [[PMMolecule alloc] initWithPoints:points andIdentifier:key];
  //    [molecules addObject:m];
  //
  //    PMHole *h = [[grid.holes objectAtIndex:points[0].x] objectAtIndex:points[0].y + 1];
  //    PMAtom *a = [[m.atoms objectAtIndex:points[0].x] objectAtIndex:points[0].y + 1];
  //
  //    GLKVector4 homogeneousCoordinate = GLKVector4Make(a.position.x, a.position.y, 0, 1);
  //    GLKVector4 homogeneousWorldCoordinate = GLKMatrix4MultiplyVector4([m modelViewMatrix], homogeneousCoordinate);
  //    GLKVector2 worldCoordinate2d = GLKVector2Make(homogeneousWorldCoordinate.x/homogeneousWorldCoordinate.w, homogeneousWorldCoordinate.y/homogeneousWorldCoordinate.w);
  //
  //    GLKVector2 offset = GLKVector2Subtract([grid getHoleWorldCoordinates:h], worldCoordinate2d);
  //    [m translate:offset];
  //
  //    [grid snapMolecule:m];
  //  }
  
  [molecules addObject:[MoleculeFactory blueMolecule]];
  [molecules addObject:[MoleculeFactory greenMolecule]];
  [molecules addObject:[MoleculeFactory yellowMolecule]];
  [molecules addObject:[MoleculeFactory whiteMolecule]];
  [molecules addObject:[MoleculeFactory orangeMolecule]];
  [molecules addObject:[MoleculeFactory redMolecule]];
  [molecules addObject:[MoleculeFactory purpleMolecule]];
  
  [self layoutMolecules];
}

- (void)layoutMolecules {
  
//  NSUInteger count = molecules.count;
//  for (NSUInteger i = 0; i < count; ++i) {
//    // Select a random element between i and end of array to swap with.
//    NSInteger nElements = count - i;
//    NSInteger n = (arc4random_uniform(nElements)) + i;
//    [molecules exchangeObjectAtIndex:i withObjectAtIndex:n];
//  }
//  for(NSUInteger i = 0; i < count; ++i) {
//    Molecule *molecule = [molecules objectAtIndex:i];
//    for (NSUInteger j = 0; j < arc4random_uniform(6); ++j) {
//      [molecule rotateClockwise];
//    }
//  }
  
  GLKVector2 directions[7] = { GLKVector2Make(0.000000f, 3.000000f), GLKVector2Make(-2.934872f, 2.038362f), GLKVector2Make(-3.871667f, -0.753814f), GLKVector2Make(-1.585160f, -2.754376f), GLKVector2Make(1.514443f, -2.776668f), GLKVector2Make(3.846348f, -0.823502f), GLKVector2Make(2.992000f, 1.991096f)};
  
  for (NSUInteger i = 0; i < molecules.count; ++i) {
    Molecule *molecule = [molecules objectAtIndex:i];
    
    [molecule translate:GLKVector2MultiplyScalar(directions[i], 96)];
    [molecule updateAabb];
    [self enforceScreenBoundsForMolecule:molecule];
  }
}

- (void)setProjection
{
  int width = (int) [self.view bounds].size.width;
  int height = (int) [self.view bounds].size.height;
  
  GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-width / 2, width / 2, -height / 2, height / 2, 0.0f, 1000.0f);
  
//  GLfloat ratio = width/height;
//  projectionMatrix = GLKMatrix4MakePerspective(90.0f, ratio, -10.0f, 10.0f);
  self.effect.transform.projectionMatrix = projectionMatrix;
  
  [self updateOnce];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) __unused fromInterfaceOrientation
{
  [self setProjection];
}

- (void)tearDownGL {
  [EAGLContext setCurrentContext:self.context];
}

- (void)updateOnce {
  self.paused = NO;
  shouldStopUpdating = YES;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update {
  if (shouldStopUpdating == YES) {
    self.paused = YES;
    shouldStopUpdating = NO;
  }
  if (finishAnimation) {
    [leftOverMolecule rotate:GLKMathDegreesToRadians(60)];
    finishTimer += 1;
    
    if(finishTimer > 7*5) {
      finishTimer = 0;
      finishAnimation = false;
      shouldStopUpdating = YES;
    }
  }
}

- (void)glkView:(GLKView *) __unused view drawInRect:(CGRect) __unused rect {
  [self render];
}

-(void)render {
  GLKVector4 bg = [[ColorTheme sharedSingleton] bg];
  glClearColor(bg.x, bg.y, bg.z, bg.w);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  [grid render:self.effect];
  
  for (Molecule *molecule in molecules) {
    [molecule render:self.effect];
  }
  
  if(pointerTouch != nil) {
    CGPoint point = [self touchPointToGLPoint:[pointerTouch locationInView:self.view]];
    [tutorial setPosition:GLKVector2Make(point.x, point.y)];
    self.effect.constantColor = activeMolecule.color;
    [tutorial render:self.effect andRotationInProgress:isRotationInProgress andMirroringInProgress:isMirroringInProgress];
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) __unused event
{
  self.paused = NO;
  
  if(finishAnimation) {
    return;
  }
  
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
  }
  else if (transformTouch == nil)
  {
    transformTouch = [touches anyObject];
    
    CGPoint pointerLocation = [pointerTouch locationInView:self.view];
    CGPoint transformLocation = [transformTouch locationInView:self.view];
    transformRotationAngle = atan2(transformLocation.y - pointerLocation.y, transformLocation.x - pointerLocation.x);
    transformMirroringOffset = transformLocation.x;
  }
}

- (CGPoint) touchPointToGLPoint:(CGPoint)point
{
  return CGPointMake( point.x - self.view.bounds.size.width / 2, -(point.y - self.view.bounds.size.height / 2) );
}

- (LinePosition)determineOnWhichSideOfLine:(CGPoint*)line LiesPoint:(CGPoint)point {
  // the pseudo distance will be zero if the point on the line
  // otherwise it will be postive for the 'right' side and negative for the
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
      [activeMolecule mirror:GLKMathDegreesToRadians(newTransformMirroringOffset - transformMirroringOffset)];
      transformMirroringOffset = newTransformMirroringOffset;
    }
    
  }
  
  [self enforceScreenBoundsForMolecule:activeMolecule];
}

- (void)enforceScreenBoundsForMolecule:(Molecule *)molecule {
  
  GLKVector2 bounding = GLKVector2Make(0, 0);
  float leftOut = molecule.aabbMin.x - (-self.view.bounds.size.width / 2);
  float rightOut = molecule.aabbMax.x - self.view.bounds.size.width / 2;
  if (leftOut < 0)
  {
    bounding.x -= leftOut;
  }
  if (rightOut > 0)
  {
    bounding.x -= rightOut;
  }
  float downOut = molecule.aabbMin.y - (-self.view.bounds.size.height / 2);
  float upOut = molecule.aabbMax.y - self.view.bounds.size.height / 2;
  if (downOut < 0)
  {
    bounding.y -= downOut;
  }
  if (upOut > 0)
  {
    bounding.y -= upOut;
  }
  [molecule translate:bounding];
}

- (void)checkForSolution
{
  if([grid isFilled]) {
    // continue updating so the finish animation can be played
    shouldStopUpdating = NO;
    
    NSString *solution = [grid toString];
    finishAnimation = YES;
    
    for (int moleculeIndex = molecules.count - 1; moleculeIndex >= 0; moleculeIndex--)
    {
      Molecule *molecule = [molecules objectAtIndex:moleculeIndex];
      if(!molecule.isSnapped) {
        leftOverMolecule = molecule;
        [molecules removeObjectAtIndex:moleculeIndex];
        [molecules addObject:leftOverMolecule];
        break;
      }
    }
    
    for(Molecule *molecule in molecules) {
    }
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *solutions = [standardUserDefaults arrayForKey:@"solutions"];
    if(solutions == nil) {
      solutions = [NSArray array];
    }
    if(![solutions containsObject:solution]) {
      [standardUserDefaults setObject:[solutions arrayByAddingObject:solution] forKey:@"solutions"];
      [standardUserDefaults synchronize];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *) __unused event
{
  for (UITouch *touch in touches)
  {
    if (pointerTouch == touch)
    {
      pointerTouch = nil;
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

@end