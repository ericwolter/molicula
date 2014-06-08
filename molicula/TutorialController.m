//
//  TutorialController.m
//  molicula
//
//  Created by Eric Wolter on 05/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "TutorialController.h"
#import "Constants.h"

#define SLIDE_DURATION 0.2f

@implementation TutorialController

- (void)setup {
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
//  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
//  UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
//  leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
//  UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
//  rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
//  UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
//  downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
  
//  [self.view addGestureRecognizer:tap];
  [self.view addGestureRecognizer:pan];
//  [self.view addGestureRecognizer:leftSwipe];
//  [self.view addGestureRecognizer:rightSwipe];
//    [self.view addGestureRecognizer:downSwipe];
  
  showFrame = self.view.frame;
  hideFrame = self.view.frame;
  hideFrame.origin.y += hideFrame.size.height;
  
  self.view.exclusiveTouch = YES;
}

CGPoint startPanCenter;
CGRect showFrame;
CGRect hideFrame;

- (void)handlePanFrom:(UIPanGestureRecognizer*)recognizer {
  MLog(@"start");
  
  CGPoint translation = [recognizer translationInView:recognizer.view];
  CGPoint velocity = [recognizer velocityInView:recognizer.view];
  
  if(recognizer.state == UIGestureRecognizerStateBegan) {
    CGPoint center = recognizer.view.center;
    MLog(@"center: %@", NSStringFromCGPoint(center));
    startPanCenter = center;
  } else if(recognizer.state == UIGestureRecognizerStateChanged) {
    MLog(@"track movement: %@", NSStringFromCGPoint(translation));
    if(fabs(translation.x) < recognizer.view.bounds.size.width / 2) {
      recognizer.view.center = CGPointMake(startPanCenter.x+translation.x, startPanCenter.y);
    }
  } else if(recognizer.state == UIGestureRecognizerStateEnded) {
    //MLog(@"animate to final position: %@", NSStringFromCGPoint(velocity));
    CGPoint futureCenter = CGPointMake(startPanCenter.x+translation.x+velocity.x, startPanCenter.y);
    //MLog(@"animate to future center: %@", NSStringFromCGPoint(futureCenter));
    if (fabs(futureCenter.x - startPanCenter.x) > recognizer.view.bounds.size.width) {
      MLog(@"animate exit");
      [UIView animateWithDuration:SLIDE_DURATION delay:0
                          options:UIViewAnimationOptionCurveEaseOut
                       animations:^ {
                         if(velocity.x < 0) {
                           recognizer.view.center = CGPointMake(startPanCenter.x-recognizer.view.bounds.size.width, startPanCenter.y);
                         } else {
                           recognizer.view.center = CGPointMake(startPanCenter.x+recognizer.view.bounds.size.width, startPanCenter.y);
                         }
                       }
                       completion:^(BOOL finished){
                         self.view.hidden = YES;
                         self.view.frame = hideFrame;
                       }];
    } else {
      MLog(@"animate snap back");
      [UIView animateWithDuration:0.2 delay:0
                          options:UIViewAnimationOptionCurveEaseOut
                       animations:^ {
                         recognizer.view.center = startPanCenter;
                       }
                       completion:NULL];
    }
  }
}

- (void)toggle {
  MLog(@"view.frame: %@", NSStringFromCGRect(self.view.frame));
  
  CGRect startFrame;
  CGRect animationFrame;
  CGRect finalFrame;
  BOOL finalHidden = NO;
  
  MLog(@"hidden: %@", (self.view.hidden ? @"YES" : @"NO"));
  if(self.view.isHidden) {
    startFrame = hideFrame;
    animationFrame = showFrame;
    finalFrame = showFrame;
    finalHidden = NO;
  } else {
    startFrame = showFrame;
    animationFrame = hideFrame;
    finalFrame = hideFrame;
    finalHidden = YES;
  }
  
  self.view.frame = startFrame;
  self.view.hidden = NO;
  
  [UIView animateWithDuration:SLIDE_DURATION
                   animations:^{
                     self.view.frame = animationFrame;
                   }
                   completion:^(BOOL finished){
                     MLog(@"completion");
                     self.view.hidden = finalHidden;
                     self.view.frame = finalFrame;
                   }];
}


@end
