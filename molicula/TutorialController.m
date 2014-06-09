//
//  TutorialController.m
//  molicula
//
//  Created by Eric Wolter on 05/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "TutorialController.h"
#import "MoveMoleculesTutorial.h"
#import "Constants.h"

#define SLIDE_DURATION 0.2f

@implementation TutorialController

- (void)setup {
  
  self.tutorials = @[
                     [[MoveMoleculesTutorial alloc] init]
                     ];
  
  for (TutorialBase *tutorial in self.tutorials) {
    tutorial.delegate = self;
  }
  
  // TODO sort tutorial by weight
  
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
  [self.view addGestureRecognizer:pan];
  
  showFrame = self.view.frame;
  showCenter = self.view.center;
  hideFrame = self.view.frame;
  hideFrame.origin.y += hideFrame.size.height;
  hideCenter = self.view.center;
  hideCenter.y += self.view.frame.size.height;
  
  self.view.exclusiveTouch = YES;
  
  self.progressView = [self.view viewWithTag:100];
  self.tutorialLabel = (UILabel *)[self.view viewWithTag:200];
  
  NSTimer *timer = [NSTimer timerWithTimeInterval:5.0f target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
  [timer setTolerance:1.0f];
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (TutorialBase *)checkTutorials {
  MLog(@"start");
  NSMutableArray *applicableTutorial = [NSMutableArray arrayWithCapacity:self.tutorials.count];
  for (TutorialBase *tutorial in self.tutorials) {
    if([tutorial checkIfApplicable]) {
      [applicableTutorial addObject:tutorial];
    }
  }
  
  if (applicableTutorial.count > 0) {
    return [applicableTutorial firstObject];
  } else {
    return nil;
  }
}

- (void)timerFireMethod:(NSTimer *)timer {
  MLog(@"start");
  
  if (self.activeTutorial) {
    MLog(@"unfinished tutorial");
    return;
  } else {
    TutorialBase *tutorial = [self checkTutorials];
    if(tutorial) {
      [tutorial startReporting];
    }
  }
}

-(void)tutorialWillAppear:(TutorialBase *)tutorial {
  self.activeTutorial = tutorial;
  
  self.tutorialLabel.text = self.activeTutorial.text;
  
  self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, 0, self.progressView.frame.size.height);
  MLog(@"show tutorial");
  
  [self toggle];
}
-(void)tutorialWillDisappear:(TutorialBase *)tutorial {
  [self toggle];
  self.activeTutorial = nil;
}

-(void)didProgressInTutorial:(TutorialBase *)tutorial toPercentage:(CGFloat)progressPercentage {
  MLog(@"start");
  
  [UIView animateWithDuration:SLIDE_DURATION
                   animations:^{
                     self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, progressPercentage * self.view.bounds.size.width, self.progressView.frame.size.height);
                   }];
}

CGPoint startPanCenter;
CGPoint showCenter;
CGPoint hideCenter;
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
                         self.view.center = hideCenter;
                         
                         [self.activeTutorial stopReporting];
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
  
  CGPoint startCenter;
  CGPoint animationCenter;
  CGPoint finalCenter;
  
  BOOL finalHidden = NO;
  
  MLog(@"hidden: %@", (self.view.hidden ? @"YES" : @"NO"));
  if(self.view.isHidden) {
    startCenter = hideCenter;
    animationCenter = showCenter;
    finalCenter = showCenter;
    finalHidden = NO;
  } else {
    startCenter = showCenter;
    animationCenter = hideCenter;
    finalCenter = hideCenter;
    finalHidden = YES;
  }
  
  self.view.center = startCenter;
  self.view.hidden = NO;
  
  [UIView animateWithDuration:SLIDE_DURATION
                   animations:^{
                     self.view.center = animationCenter;
                   }
                   completion:^(BOOL finished){
                     MLog(@"completion");
                     self.view.hidden = finalHidden;
                     self.view.center = finalCenter;
                   }];
}


@end
