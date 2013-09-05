//
//  Hole.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "Hexagon.h"

@interface Hole : Hexagon

@property id content;
@property(nonatomic) GLKVector2 logicalPosition;

@end
