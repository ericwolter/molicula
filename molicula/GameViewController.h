//
//  ViewController.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface GameViewController : GLKViewController <UIGestureRecognizerDelegate> {
  UITouch *pointerTouch;
  UITouch *transformTouch;
}

- (void)applicationWillResignActive;

@end
