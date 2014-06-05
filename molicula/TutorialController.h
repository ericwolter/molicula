//
//  TutorialController.h
//  molicula
//
//  Created by Eric Wolter on 05/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TutorialController : NSObject

@property (weak, nonatomic) UIView *view;

- (void)instantHide;
- (void)toggle;

@end
