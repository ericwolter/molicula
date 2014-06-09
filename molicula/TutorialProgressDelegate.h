//
//  TutorialProgressDelegate.h
//  molicula
//
//  Created by Eric Wolter on 08/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TutorialBase;

@protocol TutorialProgressDelegate <NSObject>

-(void)tutorialWillAppear:(TutorialBase *)tutorial;
-(void)tutorialWillDisappear:(TutorialBase *)tutorial;
-(void)didProgressInTutorial:(TutorialBase *)tutorial toPercentage:(CGFloat)progressPercentage;

@end
