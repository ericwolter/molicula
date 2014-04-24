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

@interface Hexagon : NSObject {
}

@property id parent;

@property(nonatomic) GLKVector2 position;
@property GLKMatrix4 modelViewMatrix;

- (void)render:(GLKBaseEffect *)effect;

@end
