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
#import "Controls.h"
#import "Animator.h"
#import "TranslateAnimation.h"
#import "RotationAnimation.h"
#import "GameView.h"
#import "SolutionLibrary.h"
#import "MoliculaNavigationBar.h"
#import "Metrics.h"

typedef enum {
  NoDirection,
  NegativeDirection,
  PositiveDirection
} MirroringDirection;


@interface GameViewController () {
  
  GameView *gameView;
  
  /**
   * Holds the left over molecule for the finish animation
   */
  Molecule *leftOverMolecule;
  
  bool duringDeviceRotation;
  
  /**
   * In order to conserve battery the screen is only drawn at the refresh rate
   * if the user is currently moving a molecule.
   */
  BOOL finishAnimation;
  int finishTimer;
  
  CGFloat transformRotationAngle;
  CGFloat transformMirroringOffset;
  CGFloat cumulativeMirroringAngle;
  MirroringDirection mirroringDirection;
  GLKVector2 previousTouchPoint;
  
  Controls *controls;
  UITouch *transformTouch;
  
  UITouch *pointerTouch;
  UITouch *controlTouch;
  
  /**
   * Whenever the user picks up a molecule this holds a pointer to it.
   */
  Molecule *activeMolecule;
  
  BOOL shouldStopUpdating;
  
  BOOL isRotationInProgress;
  BOOL isMirroringInProgress;
  BOOL isDisappearInProgress;
  
  Animator *animator;
}

- (CGPoint) touchPointToGLPoint:(CGPoint)point;

- (void)enforceScreenBoundsForMolecule:(Molecule *)molecule;

- (void)checkForSolution;

- (void)setupGL;
- (void)setupGrid;
- (void)tearDownGL;

- (void)layoutMolecules;
@end

@implementation GameViewController

#pragma mark - UIViewController lifecycle methods

- (void)viewDidAppear:(BOOL)animated {
  MLog(@"[begin]");
  [super viewDidAppear:animated];
  
  [self setProjection];
  
  for (NSUInteger i = 0; i < gameView.molecules.count; ++i) {
    Molecule *molecule = [gameView.molecules objectAtIndex:i];
    
    [self enforceScreenBoundsForMolecule:molecule];
  }
  MLog(@"[end]");
}

- (void)viewWillAppear:(BOOL)animated {
  MLog(@"[begin]");
  [super viewWillAppear:animated];
  
  // reset OpenGL context to global rendering context
  [EAGLContext setCurrentContext:MyAppDelegate.context];
  isDisappearInProgress = NO;
  
  // only the game view controller should allow touch events on navigation bar
  // this allows molecules to be picked up anywhere on the screen
  MoliculaNavigationBar *bar = (id)self.navigationController.navigationBar;
  bar.isTouchThroughEnabled = YES;
  MLog(@"[end]");
}

- (void)viewWillDisappear:(BOOL)animated {
  MLog(@"[begin]");
  // only the game view controller should allow touch events on navigation bar
  // this allows molecules to be picked up anywhere on the screen
  MoliculaNavigationBar *bar = (id)self.navigationController.navigationBar;
  bar.isTouchThroughEnabled = NO;
  
  [super viewWillDisappear:animated];
  MLog(@"[end]");
}

- (void)viewDidDisappear:(BOOL)animated {
  MLog(@"[begin]");
  pointerTouch = nil;
  controlTouch = nil;
  activeMolecule = nil;
  isRotationInProgress = false;
  isMirroringInProgress = false;
  cumulativeMirroringAngle = 0.0f;
  mirroringDirection = NoDirection;
  
  [super viewDidDisappear:animated];
  MLog(@"[end]");
}

- (void)viewDidLoad {
  MLog(@"[begin]");
  
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:NULL];
  
  gameView = (GameView *) self.view;
  gameView.context = MyAppDelegate.context;
  gameView.multipleTouchEnabled = YES;
  [self setPreferredFramesPerSecond:60];
  
  [gameView enableGrid];
  
  animator = [[Animator alloc] init];
  controls = [[Controls alloc] init];
  controls.parent = gameView;
  
  [self setupGL];
  [self setupGrid];
  
  MLog(@"[end]");
}

- (void)applicationWillResignActive {
  MLog(@"[begin]");
  // clear active pointers incase app is interrupted
  // otherwise the user might not be able to select another molecule once the app is active again
  pointerTouch = nil;
  transformTouch = nil;
  MLog(@"[end]");
}

-(void)dealloc {
  MLog(@"[begin]");
  [self tearDownGL];
  MLog(@"[end]");
}

- (void)setupGL {
  [EAGLContext setCurrentContext:MyAppDelegate.context];
  [controls setupBuffers];
}

- (void)tearDownGL {
  [controls tearDownBuffers];
}

- (void)setupGrid {
  [gameView addMolecule:[MoleculeFactory yellowMolecule]];
  [gameView addMolecule:[MoleculeFactory orangeMolecule]];
  [gameView addMolecule:[MoleculeFactory redMolecule]];
  [gameView addMolecule:[MoleculeFactory blueMolecule]];
  [gameView addMolecule:[MoleculeFactory greenMolecule]];
  [gameView addMolecule:[MoleculeFactory whiteMolecule]];
  [gameView addMolecule:[MoleculeFactory purpleMolecule]];
  
  [self layoutMolecules];
}

- (void)layoutMolecules {
  
  NSUInteger count = gameView.molecules.count;
//  for (NSUInteger i = 0; i < count; ++i) {
//    // Select a random element between i and end of array to swap with.
//    NSInteger nElements = count - i;
//    NSInteger n = (arc4random_uniform((unsigned int)nElements)) + i;
//    [gameView.molecules exchangeObjectAtIndex:i withObjectAtIndex:n];
//  }
  for(NSUInteger i = 0; i < count; ++i) {
    Molecule *molecule = [gameView.molecules objectAtIndex:i];
    for (NSUInteger j = 0; j < arc4random_uniform(6); ++j) {
      [molecule rotate:GLKMathDegreesToRadians(60)];
    }
  }
  
  GLKVector2 directions[7] = { GLKVector2Make(0.000000f, 3.000000f), GLKVector2Make(-2.934872f, 2.038362f), GLKVector2Make(-3.871667f, -0.753814f), GLKVector2Make(-1.585160f, -2.754376f), GLKVector2Make(1.514443f, -2.776668f), GLKVector2Make(3.846348f, -0.823502f), GLKVector2Make(2.992000f, 1.991096f)};
  
  for (NSUInteger i = 0; i < gameView.molecules.count; ++i) {
    Molecule *molecule = [gameView.molecules objectAtIndex:i];
    
    [molecule translate:GLKVector2MultiplyScalar(directions[i], LAYOUT_DISTANCE)];
  }
}

- (void)setProjection
{
  float width, height;
  if (duringDeviceRotation) {
    width = [self.view.layer.presentationLayer bounds].size.width;
    height = [self.view.layer.presentationLayer bounds].size.height;
  } else {
    width = self.view.bounds.size.width;
    height = self.view.bounds.size.height;
  }
  
  [gameView updateProjection:CGSizeMake(width, height)];
  [self updateOnce];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) __unused fromInterfaceOrientation
{
  shouldStopUpdating = YES;
  duringDeviceRotation = NO;
  [self setProjection];
  for (NSUInteger i = 0; i < gameView.molecules.count; ++i) {
    Molecule *molecule = [gameView.molecules objectAtIndex:i];
    [self enforceScreenBoundsForMolecule:molecule];
  }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  self.paused = NO;
  duringDeviceRotation = YES;
  
  pointerTouch = nil;
  controlTouch = nil;
  activeMolecule = nil;
  isRotationInProgress = false;
  isMirroringInProgress = false;
  cumulativeMirroringAngle = 0.0f;
  mirroringDirection = NoDirection;
}

- (void)updateOnce {
  self.paused = NO;
  shouldStopUpdating = YES;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update {
  if (shouldStopUpdating == YES && [animator hasRunningAnimation] == NO) {
    self.paused = YES;
    shouldStopUpdating = NO;
  } else {
    [animator update:self.timeSinceLastUpdate];
  }
  
  if(duringDeviceRotation) {
    [self setProjection];
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

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
  [gameView render];
  
  if(activeMolecule != nil) {
    [controls setPosition:[activeMolecule getCenterInObjectSpace]];
    gameView.effect.constantColor = activeMolecule.color;
    [controls render:gameView.effect andRotationInProgress:isRotationInProgress andMirroringInProgress:isMirroringInProgress];
  }
}

- (CGPoint) touchPointToGLPoint:(CGPoint)point
{
  return CGPointMake( point.x - self.view.bounds.size.width / 2, -(point.y - self.view.bounds.size.height / 2) );
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.paused = NO;
  [self update];
  
  if(finishAnimation) {
    return;
  }
  
  UITouch *touch = [touches anyObject];
  CGPoint viewCoordinate = [touch locationInView:self.view];
  GLKVector2 openglCoordinate = [gameView convertViewCoordinateToOpenGLCoordinate:viewCoordinate];
  
  if (activeMolecule != nil) {
    [activeMolecule unsnap];
    ControlTransform transform = [controls hitTest:openglCoordinate];
    switch (transform) {
      case Rotate:
        controlTouch = touch;
        isRotationInProgress = YES;
        
        GLKVector4 moleculeCenter = [activeMolecule getCenterInParentSpace];
        transformRotationAngle = atan2(openglCoordinate.y - moleculeCenter.y, openglCoordinate.x - moleculeCenter.x);
        
        return;
      case Mirror:
        controlTouch = touch;
        isMirroringInProgress = YES;
        cumulativeMirroringAngle = 0.0f;
        mirroringDirection = NoDirection;
        
        transformMirroringOffset = openglCoordinate.x;
        return;
      default:
        break;
    }
  }
  
  if (pointerTouch == nil) {

    // check if any molecule was selected
    for (NSInteger moleculeIndex = gameView.molecules.count - 1; moleculeIndex >= 0; moleculeIndex--)
    {
      Molecule *m = [gameView.molecules objectAtIndex:moleculeIndex];
      if ([m hitTest:openglCoordinate])
      {
        pointerTouch = touch;
        previousTouchPoint = openglCoordinate;
        activeMolecule = m;
        
        [Metrics sharedInstance].selectCounter++;
        
        [gameView bringToFront:moleculeIndex];
        [m unsnap];
        for(Molecule *molecule in gameView.molecules) {
          if(molecule != activeMolecule) {
            GLKQuaternion targetOrientation = [molecule snapOrientation];
            RotationAnimation *animation = [[RotationAnimation alloc] initWithMolecule:molecule AndTarget:targetOrientation];
            [animator.runningAnimation addObject:animation];
            
            DropResult *result = [gameView.grid drop:molecule withFutureOrientation:targetOrientation];
            if(result.isOverGrid) {
              TranslateAnimation *animation = [[TranslateAnimation alloc] initWithMolecule:molecule AndTarget:GLKVector2Add(molecule.position, result.offset)];
              [animator.runningAnimation addObject:animation];
              [molecule snap:result.offset toHoles:result.holes];
            }
          }
        }
        
        return;
      }
    }
  
    activeMolecule = nil;
    shouldStopUpdating = YES;
  }
}

- (CGFloat)constrainMirroring:(CGFloat)angle {
  cumulativeMirroringAngle += angle;
  if(cumulativeMirroringAngle < -M_PI_4) {
    mirroringDirection = NegativeDirection;
  } else if (cumulativeMirroringAngle > M_PI_4) {
    mirroringDirection = PositiveDirection;
  }
  
  switch (mirroringDirection) {
    case NegativeDirection:
      if (cumulativeMirroringAngle < -M_PI) {
        angle -= cumulativeMirroringAngle - (-M_PI);
        cumulativeMirroringAngle = -M_PI;
      } else if (cumulativeMirroringAngle > 0) {
        angle -= cumulativeMirroringAngle - 0;
        cumulativeMirroringAngle = 0;
      }
      break;
    case PositiveDirection:
      if (cumulativeMirroringAngle > M_PI) {
        angle -= cumulativeMirroringAngle - M_PI;
        cumulativeMirroringAngle = M_PI;
      } else if (cumulativeMirroringAngle < 0) {
        angle -= cumulativeMirroringAngle - 0;
        cumulativeMirroringAngle = 0;
      }
      break;
    default:
      break;
  }
  
  return angle;
}

NSUInteger totalDistance;

- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *)event
{
  if (!activeMolecule)
  {
    return;
  }
  
  if (pointerTouch != nil)
  {
    CGPoint viewCoordinate = [pointerTouch locationInView:self.view];
    GLKVector2 openglCoordinate = [gameView convertViewCoordinateToOpenGLCoordinate:viewCoordinate];
    GLKVector2 translate = GLKVector2Subtract(openglCoordinate, previousTouchPoint);
    
    [activeMolecule translate:translate];
    previousTouchPoint = openglCoordinate;
    
    [Metrics sharedInstance].totalTranslation += GLKVector2Length(translate);
  }
  
  if(controlTouch != nil) {
    CGPoint viewCoordinate = [controlTouch locationInView:self.view];
    GLKVector2 openglCoordinate = [gameView convertViewCoordinateToOpenGLCoordinate:viewCoordinate];
    if (isRotationInProgress) {
      GLKVector4 moleculeCenter = [activeMolecule getCenterInParentSpace];
      CGFloat newTransformRotationAngle = atan2(openglCoordinate.y - moleculeCenter.y, openglCoordinate.x - moleculeCenter.x);
      CGFloat deltaAngle = transformRotationAngle-newTransformRotationAngle;
      
      [activeMolecule rotate:deltaAngle];
      transformRotationAngle = newTransformRotationAngle;
      
      [Metrics sharedInstance].totalRotation += fabs(deltaAngle);
      
    } else if (isMirroringInProgress) {
      CGFloat newTransformMirroringOffset = openglCoordinate.x;
      CGFloat deltaAngle = GLKMathDegreesToRadians(transformMirroringOffset - newTransformMirroringOffset) * CONTROL_MIRROR_VELOCITY;
      
      [activeMolecule mirror:[self constrainMirroring:deltaAngle]];
      transformMirroringOffset = newTransformMirroringOffset;
      
      [Metrics sharedInstance].totalMirroring += fabs(deltaAngle);
      
    }
  }
  [self enforceScreenBoundsForMolecule:activeMolecule];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *) __unused event
{
  for (UITouch *touch in touches)
  {
    if (activeMolecule == nil) {
      return;
    }
    
    if (pointerTouch == touch)
    {
      pointerTouch = nil;
      shouldStopUpdating = YES;
      
      GLKQuaternion targetOrientation = [activeMolecule snapOrientation];
      RotationAnimation *animation = [[RotationAnimation alloc] initWithMolecule:activeMolecule AndTarget:targetOrientation];
      [animator.runningAnimation addObject:animation];
      
      DropResult *result = [gameView.grid drop:activeMolecule withFutureOrientation:targetOrientation];
      if(result.isOverGrid) {
        TranslateAnimation *animation = [[TranslateAnimation alloc] initWithMolecule:activeMolecule AndTarget:GLKVector2Add(activeMolecule.position, result.offset)];
        [animator.runningAnimation addObject:animation];
        if([activeMolecule snap:result.offset toHoles:result.holes]) {
          [gameView sendToBackMolecule:activeMolecule];
        }
      }
      
      [self checkForSolution];
    }
    if(controlTouch == touch) {
      controlTouch = nil;
      
      isRotationInProgress = false;
      isMirroringInProgress = false;
      
      cumulativeMirroringAngle = 0.0f;
      mirroringDirection = NoDirection;
      
      GLKQuaternion targetOrientation = [activeMolecule snapOrientation];
      RotationAnimation *animation = [[RotationAnimation alloc] initWithMolecule:activeMolecule AndTarget:targetOrientation];
      [animator.runningAnimation addObject:animation];
      
      DropResult *result = [gameView.grid drop:activeMolecule withFutureOrientation:targetOrientation];
      if(result.isOverGrid) {
        TranslateAnimation *animation = [[TranslateAnimation alloc] initWithMolecule:activeMolecule AndTarget:GLKVector2Add(activeMolecule.position, result.offset)];
        [animator.runningAnimation addObject:animation];
        if([activeMolecule snap:result.offset toHoles:result.holes]) {
          [gameView sendToBackMolecule:activeMolecule];
        }
      }
      
      if(pointerTouch == nil) {
        shouldStopUpdating = YES;
      }
      
      [self checkForSolution];
    }
  }
}

- (void)enforceScreenBoundsForMolecule:(Molecule *)molecule {
  
  CGRect boundingRect = [molecule getWorldAABB];
  
  float width, height;
  width = self.view.bounds.size.width;
  height = self.view.bounds.size.height;
  
  GLKVector2 bounding = GLKVector2Make(0, 0);
  float leftOut = CGRectGetMinX(boundingRect) - (-width / 2);
  float rightOut = CGRectGetMaxX(boundingRect) - width / 2;
  if (leftOut < 0)
  {
    bounding.x -= leftOut;
  }
  if (rightOut > 0)
  {
    bounding.x -= rightOut;
  }
  float downOut = CGRectGetMinY(boundingRect) - (-height / 2);
  float upOut = CGRectGetMaxY(boundingRect) - height / 2;
  if (downOut < 0)
  {
    bounding.y -= downOut;
  }
  if (upOut > 0)
  {
    bounding.y -= upOut;
  }
  
  GLKVector4 homogeneousCoordinate = GLKVector4Make(bounding.x, bounding.y, 0, 1);
  GLKVector4 homogeneousWorldCoordinate = GLKMatrix4MultiplyVector4(gameView.invertedModelViewMatrix, homogeneousCoordinate);
  
  bounding = GLKVector2Make(homogeneousWorldCoordinate.x/homogeneousWorldCoordinate.w, homogeneousWorldCoordinate.y/homogeneousWorldCoordinate.w);
  
  TranslateAnimation *animation = [[TranslateAnimation alloc] initWithMolecule:molecule AndTarget:GLKVector2Add(molecule.position, bounding)];
  animation.linearVelocity *= 2.0f;
  [animator.runningAnimation addObject:animation];
}

- (void)checkForSolution
{
  if([gameView.grid isFilled]) {
    // continue updating so the finish animation can be played
    shouldStopUpdating = NO;
    activeMolecule = nil;
    
    NSString *solution = [gameView.grid toString];
    finishAnimation = YES;
    
    for (NSInteger moleculeIndex = gameView.molecules.count - 1; moleculeIndex >= 0; moleculeIndex--)
    {
      Molecule *molecule = [gameView.molecules objectAtIndex:moleculeIndex];
      if(!molecule.isSnapped) {
        leftOverMolecule = molecule;
        [gameView.molecules removeObjectAtIndex:moleculeIndex];
        [gameView.molecules addObject:leftOverMolecule];
        break;
      }
    }
    
    SolutionResult result = [[SolutionLibrary sharedInstance] checkSolutionForGrid:solution WithMissingMolecule:leftOverMolecule.identifer];
    
    if(result) {
      MLog(@"result OK!");
    } else {
      MLog(@"result failed!");
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

@end