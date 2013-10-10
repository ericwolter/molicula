//
//  DroppingResult.h
//  molicula
//
//  Created by Eric Wolter on 10/10/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class Molecule;

@interface DropResult : NSObject

@property BOOL isOverGrid;
@property Molecule *molecule;
@property GLKVector2 offset;
@property NSMutableArray *holes;

@end


