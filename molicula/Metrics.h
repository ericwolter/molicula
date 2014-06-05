//
//  Metrics.h
//  molicula
//
//  Created by Eric Wolter on 05/06/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Metrics : NSObject

@property double totalTranslation;
@property double totalRotation;
@property double totalMirroring;

+ (Metrics *)sharedInstance;

@end
