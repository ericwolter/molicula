//
//  Animator.h
//  molicula
//
//  Created by Eric Wolter on 10/12/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Animator : NSObject

@property NSMutableArray *runningAnimation;

-(void)update:(NSTimeInterval)deltaT;

-(BOOL)hasRunningAnimation;

@end
