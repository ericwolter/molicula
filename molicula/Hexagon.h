//
//  Hexagon.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Constants.h"
#import "GLObject.h"

@interface Hexagon : GLModel

@property (nonatomic) GLKVector2 position;

- (void)render:(GLKBaseEffect *)effect;

@end
