//
//  ViewController.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
@import GoogleMobileAds;
#import "TutorialController.h"

@interface GameViewController : GLKViewController <UIGestureRecognizerDelegate> {
  
}

//@property (strong, nonatomic) TutorialController *tutorialController;
//@property (weak, nonatomic) IBOutlet UIView *tutorialView;
@property (weak, nonatomic) IBOutlet UIButton *restartButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *libraryButton;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

- (void)updateOnce;

@end