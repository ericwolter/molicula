//
//  ColorTheme.h
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Helper.h"

@interface ColorTheme : NSObject

+ (ColorTheme *)sharedSingleton;

-(GLKVector4)bg;
-(GLKVector4)hole;
-(GLKVector4)blue;
-(GLKVector4)red;
-(GLKVector4)green;
-(GLKVector4)yellow;
-(GLKVector4)orange;
-(GLKVector4)white;
-(GLKVector4)purple;

@end
