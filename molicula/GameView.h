//
//  GameView.h
//  molicula
//
//  Created by Eric Wolter on 24/04/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "Grid.h"

@interface GameView : NSObject <UIGestureRecognizerDelegate> {
}

@property(strong, nonatomic) GLKBaseEffect *effect;
@property GLKMatrix4 modelViewMatrix;

@property(strong, nonatomic) Grid *grid;
@property(strong, nonatomic) NSMutableArray *molecules;

- (void)updateProjection:(CGSize)size;

- (void)enableGrid;
- (void)disableGrid;

- (void)addMolecule:(Molecule *)molecule;

@end
