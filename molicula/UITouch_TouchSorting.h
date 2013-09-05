//
//  UITouch_TouchSorting.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface UITouch (TouchSorting)
- (NSComparisonResult)compareAddress:(id)obj;
@end

@implementation UITouch (TouchSorting)
- (NSComparisonResult)compareAddress:(id)obj {
  if ((__bridge void *) self < (__bridge void *) obj) {
    return NSOrderedAscending;
  } else if ((__bridge void *) self == (__bridge void *) obj) {
    return NSOrderedSame;
  } else {
    return NSOrderedDescending;
  }
}

@end
