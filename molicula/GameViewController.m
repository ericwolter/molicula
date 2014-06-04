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
  
  float trueWidth;
  float trueHeight;

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

@property(strong, nonatomic) EAGLContext *context;

- (CGPoint) touchPointToGLPoint:(CGPoint)point;

- (void)enforceScreenBoundsForMolecule:(Molecule *)molecule;

- (void)checkForSolution;

- (void)setupGL;
- (void)setupGrid;
- (void)tearDownGL;

- (void)layoutMolecules;
@end

@implementation GameViewController

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
  MLog(@"start");
  [self setupGL];
  isDisappearInProgress = NO;
  [self setProjection];
  [self updateOnce];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  //  NSLog(@"viewWillDisappear");
  //  isDisappearInProgress = YES;
  //  [self makeRectFrame];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  pointerTouch = nil;
  controlTouch = nil;
  activeMolecule = nil;
  isRotationInProgress = false;
  isMirroringInProgress = false;
  cumulativeMirroringAngle = 0.0f;
  mirroringDirection = NoDirection;
}

- (void)viewDidLoad {
  MLog("start");

  [super viewDidLoad];
  
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  
  if (!self.context) {
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:NULL];
  
  gameView = (GameView *) self.view;
  gameView.context = self.context;
  gameView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
  gameView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
  gameView.drawableMultisample = GLKViewDrawableMultisample4X;
  gameView.multipleTouchEnabled = YES;
  gameView.exclusiveTouch = YES;
  [self setPreferredFramesPerSecond:60];
  [self updateTrueSize];
  [self setupGL];
  
  [gameView enableGrid];
  
  animator = [[Animator alloc] init];
  controls = [[Controls alloc] init];
  controls.parent = gameView;
  
  [self setupGrid];
  
//  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
////  [button addTarget:self
////             action:@selector(aMethod:)
////   forControlEvents:UIControlEventTouchDown];
//  UIImage *revealIcon = [UIImage imageNamed:@"Hamburger"];
//  [button setImage:revealIcon forState:UIControlStateNormal];
//  
//  if([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
//    button.frame = CGRectMake(0.0f, 12.0f, 44.0f, 44.0f);
//  } else {
//    button.frame = CGRectMake(0.0f, 0.0f, 44.0f, 44.0f);
//  }
//  GLKVector4 c = [[ColorTheme sharedSingleton] hole];
//  button.tintColor = [UIColor colorWithRed:c.x green:c.y blue:c.z alpha:1.0f];
//  [view addSubview:button];
}

- (void)applicationWillResignActive {
  pointerTouch = nil;
  transformTouch = nil;
}

- (void)dealloc {
  MLog(@"start");
//  NSLog(@"GameViewController dealloc");
  [self tearDownGL];
  
  if ([EAGLContext currentContext] == self.context) {
    [EAGLContext setCurrentContext:nil];
  }
}

- (void)didReceiveMemoryWarning {
  MLog(@"start");

  [super didReceiveMemoryWarning];
  
//  if ([self isViewLoaded] && ([[self view] window] == nil)) {
//    self.view = nil;
//    
//    [self tearDownGL];
//    
//    if ([EAGLContext currentContext] == self.context) {
//      [EAGLContext setCurrentContext:nil];
//    }
//    self.context = nil;
//  }
  
  // Dispose of any resources that can be recreated.
}

- (void)setupGL {
  MLog(@"start");
  [EAGLContext setCurrentContext:self.context];
  [controls setupBuffers];
}

- (void)setupGrid {
  
  NSString *solution = @"000pgg00ppgg0ppyygwwoyrrwwoyr0woyr00oor000";
  NSLog(@"%@", solution);
//  NSString *swpYO = [[SolutionLibrary sharedInstance] switchYellowOrange:solution];
//  NSLog(@"%@", swpYO);
//  NSString *swpWP = [[SolutionLibrary sharedInstance] switchWhitePurple:solution];
//  NSLog(@"%@", swpWP);
//  NSString *flipH = [[SolutionLibrary sharedInstance] flipH:solution];
//  NSLog(@"%@", flipH);
  NSString *flipV = [[SolutionLibrary sharedInstance] flipV:solution];
  NSLog(@"%@", flipV);
  
//  NSArray *solutionPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"txt" inDirectory:@"solutions"];
//  NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
//  NSArray *solutions = [standardUserDefaults arrayForKey:@"solutions"];
  
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
  for (NSUInteger i = 0; i < count; ++i) {
    // Select a random element between i and end of array to swap with.
    NSInteger nElements = count - i;
    NSInteger n = (arc4random_uniform((unsigned int)nElements)) + i;
    [gameView.molecules exchangeObjectAtIndex:i withObjectAtIndex:n];
  }
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
    [self enforceScreenBoundsForMolecule:molecule];
  }
}

- (void)updateTrueSize {
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
    trueWidth = screenRect.size.height;
    trueHeight = screenRect.size.width;
  } else {
    trueWidth = screenRect.size.width;
    trueHeight = screenRect.size.height;
  }
}

- (void)makeSquareFrame {
//  NSLog(@"makeSquareFrame");
//  NSLog(@"self.view.bounds.origin:(%f,%f)",self.view.bounds.origin.x,self.view.bounds.origin.y);
//  NSLog(@"self.view.bounds.size:(%f,%f)",self.view.bounds.size.width,self.view.bounds.size.height);
//  NSLog(@"self.view.frame.origin:(%f,%f)",self.view.frame.origin.x,self.view.frame.origin.y);
//  NSLog(@"self.view.frame.size:(%f,%f)",self.view.frame.size.width,self.view.frame.size.height);
  float size = self.view.frame.size.width > self.view.frame.size.height ?
  self.view.frame.size.width : self.view.frame.size.height;

  float offset_x = size - self.view.frame.size.width;
  float offset_y = size - self.view.frame.size.height;

  [self.view setFrame:CGRectMake(
                                 -offset_x/2.0f,
                                 -offset_y/2.0f,
                                 size,
                                 size)];
  [self setProjection];
}

- (void)makeRectFrame {
//  NSLog(@"makeRectFrame");
//  NSLog(@"self.view.bounds.origin:(%f,%f)",self.view.bounds.origin.x,self.view.bounds.origin.y);
//  NSLog(@"self.view.bounds.size:(%f,%f)",self.view.bounds.size.width,self.view.bounds.size.height);
//  NSLog(@"self.view.frame.origin:(%f,%f)",self.view.frame.origin.x,self.view.frame.origin.y);
//  NSLog(@"self.view.frame.size:(%f,%f)",self.view.frame.size.width,self.view.frame.size.height);
  
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  [self.view setFrame:CGRectMake(0.0f,0.0f, screenRect.size.width, screenRect.size.height)];
  if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
    [self.view setFrame:CGRectMake(0.0f,0.0f, screenRect.size.height, screenRect.size.width)];
  }

  [self setProjection];
}

- (void)viewWillLayoutSubviews {
//  if(!isDisappearInProgress) {
//    [self makeSquareFrame];
//  }
}

- (void)setProjection
{
  float width, height;
  width = [self.view.layer.presentationLayer bounds].size.width;
  height = [self.view.layer.presentationLayer bounds].size.height;
  
  [gameView updateProjection:CGSizeMake(width, height)];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) __unused fromInterfaceOrientation
{
  shouldStopUpdating = YES;
  duringDeviceRotation = NO;
  [self setProjection];
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

  if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) !=
      UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
    float tmp = trueHeight;
    trueHeight = trueWidth;
    trueWidth = tmp;
  }
  
  for (NSUInteger i = 0; i < gameView.molecules.count; ++i) {
    Molecule *molecule = [gameView.molecules objectAtIndex:i];
    [self enforceScreenBoundsForMolecule:molecule];
  }
}

- (void)tearDownGL {
  
  MLog(@"start");
  MLog(@"%@",self.context);
  [controls tearDownBuffers];
  [EAGLContext setCurrentContext:self.context];
}

- (void)updateOnce {
  self.paused = NO;
  shouldStopUpdating = YES;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update {
  MLog(@"start");
  if (shouldStopUpdating == YES && [animator hasRunningAnimation] == NO) {
    self.paused = YES;
    shouldStopUpdating = NO;
  } else {
    [self setProjection];
    [animator update:self.timeSinceLastUpdate];
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
  MLog(@"start");
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) __unused event
{
  self.paused = NO;
  [self update];
  
  if(finishAnimation) {
    return;
  }
  
  UITouch *touch = [touches anyObject];
  CGPoint viewCoordinate = [touch locationInView:self.view];
//  NSLog(@"touchesBegan: viewCoordinate: %@", NSStringFromCGPoint(viewCoordinate));
  GLKVector2 openglCoordinate = [gameView convertViewCoordinateToOpenGLCoordinate:viewCoordinate];
//  NSLog(@"touchesBegan: openglCoordinate: %@", NSStringFromGLKVector2(openglCoordinate));
  
  if (activeMolecule != nil) {
    [activeMolecule unsnap];
    ControlTransform transform = [controls hitTest:openglCoordinate];
    switch (transform) {
      case Rotate:
//        NSLog(@"Control Rotate");
        controlTouch = touch;
        isRotationInProgress = YES;
        
        GLKVector4 moleculeCenter = [activeMolecule getCenterInParentSpace];
        transformRotationAngle = atan2(openglCoordinate.y - moleculeCenter.y, openglCoordinate.x - moleculeCenter.x);
        
        return;
      case Mirror:
//        NSLog(@"Control Mirror");
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
//        NSLog(@"molecule hit!");
        pointerTouch = touch;
        previousTouchPoint = openglCoordinate;
        activeMolecule = m;
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
        // only a single molecule can be selected -> so stop here
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
  
//  NSLog(@"delta, cum: %f,%f", angle, cumulativeMirroringAngle);
  switch (mirroringDirection) {
    case NegativeDirection:
      if (cumulativeMirroringAngle < -M_PI) {
        angle -= cumulativeMirroringAngle - (-M_PI);
        cumulativeMirroringAngle = -M_PI;
//        NSLog(@"-< delta, cum: %f,%f", angle, cumulativeMirroringAngle);
      } else if (cumulativeMirroringAngle > 0) {
        angle -= cumulativeMirroringAngle - 0;
        cumulativeMirroringAngle = 0;
//        NSLog(@"-> delta, cum: %f,%f", angle, cumulativeMirroringAngle);
      }
      break;
    case PositiveDirection:
      if (cumulativeMirroringAngle > M_PI) {
        angle -= cumulativeMirroringAngle - M_PI;
        cumulativeMirroringAngle = M_PI;
//        NSLog(@"+> delta, cum: %f,%f", angle, cumulativeMirroringAngle);
      } else if (cumulativeMirroringAngle < 0) {
        angle -= cumulativeMirroringAngle - 0;
        cumulativeMirroringAngle = 0;
//        NSLog(@"+< delta, cum: %f,%f", angle, cumulativeMirroringAngle);
      }
      break;
    default:
      break;
  }
  
  return angle;
}

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
  }
  
  if(controlTouch != nil) {
    CGPoint viewCoordinate = [controlTouch locationInView:self.view];
    GLKVector2 openglCoordinate = [gameView convertViewCoordinateToOpenGLCoordinate:viewCoordinate];
    if (isRotationInProgress) {
      GLKVector4 moleculeCenter = [activeMolecule getCenterInParentSpace];
      CGFloat newTransformRotationAngle = atan2(openglCoordinate.y - moleculeCenter.y, openglCoordinate.x - moleculeCenter.x);
      [activeMolecule rotate:transformRotationAngle-newTransformRotationAngle];
      transformRotationAngle = newTransformRotationAngle;
    } else if (isMirroringInProgress) {
      CGFloat newTransformMirroringOffset = openglCoordinate.x;
      CGFloat deltaAngle = GLKMathDegreesToRadians(transformMirroringOffset - newTransformMirroringOffset) * CONTROL_MIRROR_VELOCITY;
      [activeMolecule mirror:[self constrainMirroring:deltaAngle]];
      transformMirroringOffset = newTransformMirroringOffset;
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
        [activeMolecule snap:result.offset toHoles:result.holes];
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
        [activeMolecule snap:result.offset toHoles:result.holes];
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
  
//  NSLog(@"boundingRect: %@", NSStringFromCGRect(boundingRect));
  GLKVector2 bounding = GLKVector2Make(0, 0);
  float leftOut = CGRectGetMinX(boundingRect) - (-trueWidth / 2);
  float rightOut = CGRectGetMaxX(boundingRect) - trueWidth / 2;
  if (leftOut < 0)
  {
    bounding.x -= leftOut;
  }
  if (rightOut > 0)
  {
    bounding.x -= rightOut;
  }
  float downOut = CGRectGetMinY(boundingRect) - (-trueHeight / 2);
  float upOut = CGRectGetMaxY(boundingRect) - trueHeight / 2;
  if (downOut < 0)
  {
    bounding.y -= downOut;
  }
  if (upOut > 0)
  {
    bounding.y -= upOut;
  }
//  const float precision = 1e5;
//  bounding.x = roundf(bounding.x*precision) / precision;
//  bounding.y = roundf(bounding.y*precision) / precision;
//  NSLog(@"boundingOffset: %@",NSStringFromGLKVector2(bounding));
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