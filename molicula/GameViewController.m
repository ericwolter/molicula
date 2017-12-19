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
#import "Helper.h"

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

- (GLKVector2)calculateBoundsVectorForMolecule:(Molecule *)molecule withTranslation:(GLKVector2)translation andOrientation:(GLKQuaternion)orientation;
- (void)enforceScreenBoundsForMolecule:(Molecule *)molecule;

- (void)checkForSolution;

- (void)setupGL;
- (void)setupGrid;
- (void)tearDownGL;

- (void)randomizeLayout:(BOOL)animated;
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

-(void)makeViewShine:(UIView*) view
{
  ColorTheme *theme = [ColorTheme sharedSingleton];
  UIColor *shine = [UIColor colorWithRed:[theme hole].x green:[theme hole].y blue:[theme hole].z alpha:1.0f];
  view.layer.shadowColor = shine.CGColor;
  view.layer.shadowRadius = 0.0f;
  view.layer.shadowOpacity = 1.0f;
  view.layer.shadowOffset = CGSizeZero;
  
  CABasicAnimation *animationRadius=[CABasicAnimation animationWithKeyPath:@"shadowRadius"];
  animationRadius.fromValue=[NSNumber numberWithFloat:0.0f];
  animationRadius.toValue=[NSNumber numberWithFloat:10.0f];
  CABasicAnimation *animationOpacity=[CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
  animationOpacity.fromValue=[NSNumber numberWithFloat:0.0f];
  animationOpacity.toValue=[NSNumber numberWithFloat:1.0f];
  CABasicAnimation *animationScale=[CABasicAnimation animationWithKeyPath:@"transform"];
  animationScale.toValue=[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.15f, 1.15f, 1.0f)];
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.duration = 1.0f;
  group.repeatCount = 7;
  group.autoreverses = YES;
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  group.animations = @[animationRadius,animationScale];
  
  [view.layer addAnimation:group forKey:@"libraryAnimation"];
}

- (void)viewWillAppear:(BOOL)animated {
  MLog(@"[begin]");
  [super viewWillAppear:animated];
  [self.navigationItem setLeftBarButtonItem:nil animated:NO];
  
  // reset OpenGL context to global rendering context
  [EAGLContext setCurrentContext:MyAppDelegate.context];
  isDisappearInProgress = NO;
  
  // only the game view controller should allow touch events on navigation bar
  // this allows molecules to be picked up anywhere on the screen
  MoliculaNavigationBar *bar = (id)self.navigationController.navigationBar;
  bar.isTouchThroughEnabled = YES;
  
  [self checkForSolution];
  
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

#ifndef MAKE_SCREENSHOT
//  NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
  self.bannerView.adUnitID = @"ca-app-pub-5717136270400903/1281141100";
  self.bannerView.rootViewController = self;
  [self.bannerView loadRequest:[self createRequest]];
  
  // workaround for scroll offset issue
  // see: http://stackoverflow.com/questions/24763692/admob-ios-banner-offset-issue
  UIView *view = [[UIView alloc] init];
  [self.view insertSubview:view belowSubview:self.bannerView];
#endif
  
  MLog(@"[end]");
}

#pragma mark GADRequest generation

// Here we're creating a simple GADRequest and whitelisting the application
// for test ads. You should request test ads during development to avoid
// generating invalid impressions and clicks.
- (GADRequest *)createRequest {
  GADRequest *request = [GADRequest request];
  
  // Make the request for a test ad. Put in an identifier for the simulator as
  // well as any devices you want to receive test ads.
  request.testDevices = @[ kGADSimulatorID, @"124951ea9459d87245681f1666e46039" ];
  return request;
}

#pragma mark GADBannerViewDelegate callbacks

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  NSLog(@"Received ad successfully");
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
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
  [gameView addMolecule:[MoleculeFactory blueMolecule]];
  [gameView addMolecule:[MoleculeFactory greenMolecule]];
  [gameView addMolecule:[MoleculeFactory yellowMolecule]];
  [gameView addMolecule:[MoleculeFactory whiteMolecule]];
  [gameView addMolecule:[MoleculeFactory orangeMolecule]];
  [gameView addMolecule:[MoleculeFactory redMolecule]];
  [gameView addMolecule:[MoleculeFactory purpleMolecule]];
  
  [self randomizeLayout:NO];
}

/**
 *  Description
 */
- (void)setProjection
{
  float width, height;
  // during rotation we want to resize the view continuously
  // however the views bounds are only updated at the very end
  // the presentation layer is however updating throughout the rotation
  // TODO: presentation layer bounds still seem to lag a few frames
  //       resulting in a noticable wobble effect
  CGSize currentSize = [self.view.layer.presentationLayer bounds].size;
  width = currentSize.width;
  height = currentSize.height;
    
  // set the new projection on the actual render view
  [gameView updateProjection:CGSizeMake(width, height)];
  
  // update screen once to reflect the new projection
  [self updateOnce];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  MLog(@"start");
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  
  self.paused = NO;
  
  pointerTouch = nil;
  controlTouch = nil;
  activeMolecule = nil;
  isRotationInProgress = false;
  isMirroringInProgress = false;
  cumulativeMirroringAngle = 0.0f;
  mirroringDirection = NoDirection;
  
  [coordinator animateAlongsideTransitionInView:self.view animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
  } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    // update control flags
    shouldStopUpdating = YES;
    
    [self setProjection];
    
    // because of the rotation some molecules are now either completely
    // or partially of screen. We have to force them back onto the screen
    // so that the player can continue to interact with them
    for (NSUInteger i = 0; i < gameView.molecules.count; ++i) {
      Molecule *molecule = [gameView.molecules objectAtIndex:i];
      [self enforceScreenBoundsForMolecule:molecule];
    }
  }];
}

/**
 *  Updates the screen once by enabling rendering and at the same time
 *  already setting the flag to stop rendering after the next update
 */
- (void)updateOnce {
  self.paused = NO;
  shouldStopUpdating = YES;
}

#pragma mark - GLKView and GLKViewController delegate methods

/**
 *  Continuously called by the render loop
 */
- (void)update {
  
  // if we should stop
  if (shouldStopUpdating == YES && [animator hasRunningAnimation] == NO) {
    self.paused = YES;
    shouldStopUpdating = NO;
  } else {
    [animator update:self.timeSinceLastUpdate];
  }
  
  // continuously update the projection during device rotation to provide
  // a smooth transition between the orientations
  [self setProjection];
  
  // execute the finish animation: rotating the left over molecule quickly multiple times
  if (finishAnimation) {
    [leftOverMolecule rotate:GLKMathDegreesToRadians(60)];
    finishTimer += 1;
    
    // finish rotating after hard-coded number of rotations
    // rendering will stop after the next pass
    if(finishTimer > 7*5) {
      finishTimer = 0;
      finishAnimation = false;
      shouldStopUpdating = YES;
    }
  }
  
}

/**
 *  Continuously called by the render loop
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
  [gameView render];
  
  if(activeMolecule != nil) {
    [controls setPosition:[activeMolecule getCenterInObjectSpace]];
    gameView.effect.constantColor = activeMolecule.color;
    [controls render:gameView.effect andRotationInProgress:isRotationInProgress andMirroringInProgress:isMirroringInProgress];
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.paused = NO;
  [self update];
  
  // do not allow touch input during the finish animation
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

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *) __unused event
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

- (GLKVector2)calculateBoundsVectorForMolecule:(Molecule *)molecule withTranslation:(GLKVector2)translation andOrientation:(GLKQuaternion)orientation {
  CGRect screenRect = self.view.bounds;
#ifdef MAKE_SCREENSHOT
  screenRect = CGRectMake(screenRect.origin.x, screenRect.origin.y, screenRect.size.width - 20,  screenRect.size.height - 20);
#endif
  CGRect adRect = self.bannerView.frame;
  
  adRect = CGRectMake(adRect.origin.x, screenRect.size.height - adRect.origin.y - adRect.size.height, adRect.size.width, adRect.size.height);
  CGRect moleculeRectInOpenGL = [molecule getWorldAABBWithTranslation:translation andOrientation:orientation];
  CGRect moleculeRect = CGRectOffset(moleculeRectInOpenGL, screenRect.size.width/2, screenRect.size.height/2);
  
  if (@available(iOS 11.0, *)) {
    MoliculaNavigationBar *bar = (id)self.navigationController.navigationBar;
    UIEdgeInsets insets = self.view.safeAreaInsets;
    screenRect.origin.x += insets.left;
    screenRect.origin.y += insets.bottom;
    screenRect.size.width -= (insets.left + insets.right);
    screenRect.size.height -= (insets.top + insets.bottom - bar.frame.size.height);
  }
  
  GLKVector2 keepInsideVector = [Helper keepRect:moleculeRect insideOf:screenRect];
  // simulate moved molecule
  moleculeRect = CGRectOffset(moleculeRect, keepInsideVector.x, keepInsideVector.y);
#ifndef MAKE_SCREENSHOT
  GLKVector2 keepOutsideVector = [Helper keepRect:moleculeRect outsideOf:adRect];
#else
  GLKVector2 keepOutsideVector = GLKVector2Make(0, 0);
#endif
  
  GLKVector2 boundsVector = GLKVector2Add(keepInsideVector, keepOutsideVector);
  
  GLKVector4 homogeneousCoordinate = GLKVector4Make(boundsVector.x, boundsVector.y, 0, 1);
  GLKVector4 homogeneousWorldCoordinate = GLKMatrix4MultiplyVector4(gameView.invertedModelViewMatrix, homogeneousCoordinate);
  
  boundsVector = GLKVector2Make(homogeneousWorldCoordinate.x/homogeneousWorldCoordinate.w, homogeneousWorldCoordinate.y/homogeneousWorldCoordinate.w);
  return boundsVector;
}

- (void)enforceScreenBoundsForMolecule:(Molecule *)molecule {
  GLKVector2 boundsVector = [self calculateBoundsVectorForMolecule:molecule withTranslation:GLKVector2Make(0, 0) andOrientation:molecule.orientation];
  
  TranslateAnimation *animation = [[TranslateAnimation alloc] initWithMolecule:molecule AndTarget:GLKVector2Add(molecule.position, boundsVector)];
  animation.linearVelocity *= 2.0f;
  [animator.runningAnimation addObject:animation];
}

- (void)randomizeLayout:(BOOL)animated; {
  const GLKQuaternion orientations[12] = {
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(60), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(120), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(240), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(300), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(60), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(120), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(240), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 1, 0))),
    GLKQuaternionNormalize(GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(300), 0, 0, 1), GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(180), 0, 1, 0))),
  };
  
#ifndef MAKE_SCREENSHOT
  NSUInteger count = gameView.molecules.count;
  for (NSUInteger i = 0; i < count; ++i) {
    // Select a random element between i and end of array to swap with.
    NSInteger nElements = count - i;
    NSInteger n = (arc4random_uniform((unsigned int)nElements)) + i;
    GLKVector2 tmp = HEPTAGON[i];
    HEPTAGON[i] = HEPTAGON[n];
    HEPTAGON[n] = tmp;
  }
#endif

  for (NSUInteger i = 0; i < count; ++i) {
    Molecule *molecule = [gameView.molecules objectAtIndex:i];
    [molecule unsnap];
    
    GLKVector2 targetPosition = GLKVector2MultiplyScalar(HEPTAGON[i], LAYOUT_DISTANCE);
    GLKVector2 targetTranslation = GLKVector2Subtract(targetPosition, molecule.position);
    GLKQuaternion targetOrientation = orientations[arc4random_uniform(12)];
    
    GLKVector2 boundsVector = [self calculateBoundsVectorForMolecule:molecule withTranslation:targetTranslation andOrientation:targetOrientation];
    targetPosition = GLKVector2Add(targetPosition, boundsVector);
    
    if(animated) {
      TranslateAnimation *animation = [[TranslateAnimation alloc] initWithMolecule:molecule AndTarget:targetPosition];
      animation.linearVelocity *= 2.0f;
      [animator.runningAnimation addObject:animation];
      
      RotationAnimation *rotateAnimation = [[RotationAnimation alloc] initWithMolecule:molecule AndTarget:targetOrientation];
      [animator.runningAnimation addObject:rotateAnimation];
    } else {
      [molecule setPosition:targetPosition];
#ifndef MAKE_SCREENSHOT
      [molecule setOrientation:targetOrientation];
#endif
    }
  }
}

- (IBAction)shareButtonTapped:(id)sender {
//  [self randomizeLayout:YES];
//  NSString *linkToShare = @"http://appstore.com/molicula";
//  NSString *textToShare = [NSString stringWithFormat:@"I just found another solution in molicula! Can you find them all? Try it here: %@", linkToShare];
//  NSURL *urlToShare = [NSURL URLWithString:linkToShare];
//  
//  NSArray *objectsToShare = @[textToShare, urlToShare];
//  
//  UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
//  
//  NSArray *excludeActivities = @[UIActivityTypeAirDrop,
//                                 UIActivityTypePrint,
//                                 UIActivityTypeCopyToPasteboard,
//                                 UIActivityTypeAssignToContact,
//                                 UIActivityTypeSaveToCameraRoll,
//                                 UIActivityTypeAddToReadingList,
//                                 UIActivityTypePostToFlickr,
//                                 UIActivityTypePostToVimeo];
//  
//  activityVC.excludedActivityTypes = excludeActivities;
//  
//  [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)showShareButton {
//  [self.navigationItem setLeftBarButtonItem:self.shareButton animated:YES];
}

- (void)hideShareButton {
//  [self.navigationItem setLeftBarButtonItem:nil animated:YES];
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
    
    SolutionLibrary *library = [SolutionLibrary sharedInstance];
    if(![solution isEqualToString:library.currentSolution]) {
      library.currentSolutionIsBrandNew = NO;
    }
    library.currentSolution = solution;
    
    SolutionResult result = [library recordSolution:solution WithMissingMolecule:leftOverMolecule.identifer];
    if (result == SolutionIsBrandNew) {
      [self makeViewShine:[self.libraryButton valueForKey:@"view"]];
      library.currentSolutionIsBrandNew = YES;
    }
    [self showShareButton];
    [self.restartButton setTitleColor:[leftOverMolecule getUIColor] forState:UIControlStateNormal];
    [UIView transitionWithView:self.restartButton duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
      [self.restartButton setHidden:NO];
    } completion:nil];
  } else {
    [self hideShareButton];
    self.restartButton.hidden = YES;
  }
}
- (IBAction)restartButtonTapped:(id)sender {
  SolutionLibrary *library = [SolutionLibrary sharedInstance];
  library.currentSolution = @"";
  [self randomizeLayout:YES];

  [UIView transitionWithView:self.restartButton duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
    [self.restartButton setHidden:YES];
  } completion:nil];
}

@end
