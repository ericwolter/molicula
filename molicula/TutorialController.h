//
//  TutorialController.h
//  molicula
//
//  Created by Eric Wolter on 05/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutorialProgressDelegate.h"
@class TutorialBase;

@interface TutorialController : NSObject <TutorialProgressDelegate>

@property (weak, nonatomic) UIView *view;
@property (weak, nonatomic) UIView *progressView;
@property (weak, nonatomic) UILabel *tutorialLabel;
@property (nonatomic) NSArray *tutorials;

@property TutorialBase *activeTutorial;

- (void)toggle;
- (void)setup;

@end
