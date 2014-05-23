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
  GLuint vertexBuffer;
}

@property (weak, nonatomic) id parent;

@property (nonatomic) GLKVector2 position;
@property (nonatomic) GLKMatrix4 modelViewMatrix;
@property (nonatomic) GLKMatrix4 objectMatrix;

- (void)render:(GLKBaseEffect *)effect;

@end
