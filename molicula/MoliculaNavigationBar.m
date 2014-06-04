//
//  MoliculaNavigationBar.m
//  molicula
//
//  Created by Eric Wolter on 04/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "MoliculaNavigationBar.h"
#import "Constants.h"

@implementation MoliculaNavigationBar

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  if (self.isTouchThroughEnabled) {
    id hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self) {
      return nil;
      
    } else {
      return hitView;
    }
  } else {
    return [super hitTest:point withEvent:event];
  }
}

@end
