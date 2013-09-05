//
//  Hexagon.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

static const float HEXAGON_HEIGHT = 2.0f;
static const float HEXAGON_WIDTH = (2.0f * HEXAGON_HEIGHT) / 1.73205080757; // (2 * h) / sqrt(3)
static const float HEXAGON_HALF_WIDTH = HEXAGON_WIDTH / 2.0f;
static const float HEXAGON_NARROW_WIDTH = HEXAGON_HALF_WIDTH + HEXAGON_WIDTH / 4.0f;

static const float CIRCLE_SCALE = 0.9f;
static const float CIRCLE_RADIUS = (HEXAGON_HEIGHT / 2.0f) * CIRCLE_SCALE;
static const int CIRCLE_RESOLUTION = 64;

@interface Hexagon : NSObject {
  GLKVector2 vertices[CIRCLE_RESOLUTION];
  GLuint vertexBuffer;
}

@property id parent;

@property(nonatomic) GLKVector2 position;
@property GLKMatrix4 modelViewMatrix;

- (void)render:(GLKBaseEffect *)effect;

@end
