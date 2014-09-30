//
//  TutorialBase.h
//  molicula
//
//  Created by Eric Wolter on 08/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutorialProgressDelegate.h"

@interface TutorialBase : NSObject

// used to provide logical ordering of tutorials
// this allows for a clear path of progression
@property NSUInteger weight;
@property NSString* text;
@property id<TutorialProgressDelegate> delegate;

@property double lasttime;
@property NSUInteger showCount;
@property double startValue;
@property double currentValue;
@property double currentPercentage;
@property double amount;

-(BOOL)checkIfApplicable;

-(void)startReporting;
-(void)stopReporting;

-(BOOL)isFinished;

@end
