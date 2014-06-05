//
//  TutorialController.m
//  molicula
//
//  Created by Eric Wolter on 05/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "TutorialController.h"
#import "Constants.h"

#define SLIDE_DURATION 0.5f

@implementation TutorialController

- (void)instantHide {
//  MLog(@"before view.frame: %@", NSStringFromCGRect(self.view.frame));
//  if(!self.view.hidden) {
//    CGRect newFrame = self.view.frame;
//    newFrame.origin.y += self.view.frame.size.height;
//    self.view.frame = newFrame;
//    self.view.hidden = NO;
//  }
//  MLog(@"after view.frame: %@", NSStringFromCGRect(self.view.frame));
}

- (void)toggle {
  MLog(@"view.frame: %@", NSStringFromCGRect(self.view.frame));
  
  CGRect startFrame = self.view.frame;
  CGRect animationFrame = self.view.frame;
  CGRect finalFrame = self.view.frame;
  
  BOOL finalHidden = NO;
  
  MLog(@"hidden: %@", (self.view.hidden ? @"YES" : @"NO"));
  if(self.view.isHidden) {
    startFrame.origin.y += self.view.frame.size.height;
    animationFrame = finalFrame;
    finalHidden = NO;
  } else {
    startFrame = self.view.frame;
    animationFrame.origin.y += self.view.frame.size.height;
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
