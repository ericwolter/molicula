//
//  ColorTheme.m
//  molicula
//
//  Created by Eric Wolter on 9/4/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "ColorTheme.h"

#define THEME_5

@implementation ColorTheme

+ (ColorTheme *)sharedSingleton
{
  static ColorTheme *sharedSingleton;
  
  @synchronized(self)
  {
    if (!sharedSingleton)
      sharedSingleton = [[ColorTheme alloc] init];
    
    return sharedSingleton;
  }
}

#if defined(THEME_ERIC_LETTERPESS)
-(GLKVector4)bg {
  return GLKVector4Make(RGB(240.0f), RGB(239.0f), RGB(236.0f), 1);
}

-(GLKVector4)hole {
  return GLKVector4Make(RGB(84.0f), RGB(84.0f), RGB(84.0f), 1);
}

-(GLKVector4)blue {
  return GLKVector4Make(RGB(0), RGB(162.0f), RGB(255.0f), 1);
}

-(GLKVector4)red {
  return GLKVector4Make(RGB(255.0f), RGB(67.0f), RGB(47.0f), 1);
}

-(GLKVector4)green {
  return GLKVector4Make(RGB(92.0f), RGB(255.0f), RGB(41.0f), 1);
}

-(GLKVector4)yellow {
  return GLKVector4Make(RGB(255.0f), RGB(255.0f), RGB(58.0f), 1);
}

-(GLKVector4)orange {
  return GLKVector4Make(RGB(255.0f), RGB(152.0f), RGB(49.0f), 1);
}

-(GLKVector4)white {
  return GLKVector4Make(RGB(203.0f), RGB(203.0f), RGB(203.0f), 1);
}

-(GLKVector4)purple {
  return GLKVector4Make(RGB(214.0f), RGB(102.0f), RGB(255.0f), 1);
}
#elif defined(THEME_THERESA_1)
-(GLKVector4)bg {
  return GLKVector4Make(RGB(240.0f), RGB(239.0f), RGB(236.0f), 1);
}

-(GLKVector4)hole {
  return GLKVector4Make(RGB(84.0f), RGB(84.0f), RGB(84.0f), 1);
}

-(GLKVector4)blue {
  return GLKVector4Make(RGB(9), RGB(128), RGB(186), 1);
}

-(GLKVector4)red {
  return GLKVector4Make(RGB(172), RGB(16), RGB(20), 1);
}

-(GLKVector4)green {
  return GLKVector4Make(RGB(135), RGB(200), RGB(10), 1);
}

-(GLKVector4)yellow {
  return GLKVector4Make(RGB(255), RGB(205), RGB(0), 1);
}

-(GLKVector4)orange {
  return GLKVector4Make(RGB(255), RGB(115), RGB(0), 1);
}

-(GLKVector4)white {
  return GLKVector4Make(RGB(203.0f), RGB(203.0f), RGB(203.0f), 1);
}

-(GLKVector4)purple {
  return GLKVector4Make(RGB(101), RGB(40), RGB(107), 1);
}
#elif defined(THEME_THERESA_2)
-(GLKVector4)bg {
  return GLKVector4Make(RGB(240.0f), RGB(239.0f), RGB(236.0f), 1);
}

-(GLKVector4)hole {
  return GLKVector4Make(RGB(84.0f), RGB(84.0f), RGB(84.0f), 1);
}

-(GLKVector4)blue {
  return GLKVector4Make(RGB(17), RGB(140), RGB(199), 1);
}

-(GLKVector4)red {
  return GLKVector4Make(RGB(181), RGB(9), RGB(29), 1);
}

-(GLKVector4)green {
  return GLKVector4Make(RGB(135), RGB(200), RGB(10), 1);
}

-(GLKVector4)yellow {
  return GLKVector4Make(RGB(255), RGB(205), RGB(0), 1);
}

-(GLKVector4)orange {
  return GLKVector4Make(RGB(255), RGB(124), RGB(29), 1);
}

-(GLKVector4)white {
  return GLKVector4Make(RGB(203.0f), RGB(203.0f), RGB(203.0f), 1);
}

-(GLKVector4)purple {
  return GLKVector4Make(RGB(123), RGB(42), RGB(130), 1);
}
#elif defined(THEME_THERESA_3)
-(GLKVector4)bg {
  return GLKVector4Make(RGB(240.0f), RGB(239.0f), RGB(236.0f), 1);
}

-(GLKVector4)hole {
  return GLKVector4Make(RGB(84.0f), RGB(84.0f), RGB(84.0f), 1);
}

-(GLKVector4)blue {
  return GLKVector4Make(RGB(17), RGB(140), RGB(199), 1);
}

-(GLKVector4)red {
  return GLKVector4Make(RGB(181), RGB(9), RGB(29), 1);
}

-(GLKVector4)green {
  return GLKVector4Make(RGB(135), RGB(200), RGB(10), 1);
}

-(GLKVector4)yellow {
  return GLKVector4Make(RGB(255), RGB(205), RGB(0), 1);
}

-(GLKVector4)orange {
  return GLKVector4Make(RGB(255), RGB(124), RGB(29), 1);
}

-(GLKVector4)white {
  return GLKVector4Make(RGB(203.0f), RGB(203.0f), RGB(203.0f), 1);
}

-(GLKVector4)purple {
  return GLKVector4Make(RGB(123), RGB(42), RGB(130), 1);
}
#elif defined(THEME_THERESA_4)
-(GLKVector4)bg {
  return GLKVector4Make(RGB(240.0f), RGB(239.0f), RGB(236.0f), 1);
}

-(GLKVector4)hole {
  return GLKVector4Make(RGB(84.0f), RGB(84.0f), RGB(84.0f), 1);
}

-(GLKVector4)blue {
  return GLKVector4Make(RGB(17), RGB(140), RGB(199), 1);
}

-(GLKVector4)red {
  return GLKVector4Make(RGB(181), RGB(9), RGB(29), 1);
}

-(GLKVector4)green {
  return GLKVector4Make(RGB(135), RGB(200), RGB(10), 1);
}

-(GLKVector4)yellow {
  return GLKVector4Make(RGB(255), RGB(205), RGB(0), 1);
}

-(GLKVector4)orange {
  return GLKVector4Make(RGB(255), RGB(124), RGB(29), 1);
}

-(GLKVector4)white {
  return GLKVector4Make(RGB(203.0f), RGB(203.0f), RGB(203.0f), 1);
}

-(GLKVector4)purple {
  return GLKVector4Make(RGB(123), RGB(42), RGB(130), 1);
}
#elif defined(THEME_5)
-(GLKVector4)bg {
  return GLKVector4Make(RGB(240.0f), RGB(239.0f), RGB(236.0f), 1);
}

-(GLKVector4)hole {
  return GLKVector4Make(RGB(109.0f), RGB(109.0f), RGB(107.0f), 1);
}

-(GLKVector4)blue {
  return GLKVector4Make(RGB(17), RGB(140), RGB(199), 1);
}

-(GLKVector4)red {
  return GLKVector4Make(RGB(181), RGB(9), RGB(29), 1);
}

-(GLKVector4)green {
  return GLKVector4Make(RGB(135), RGB(200), RGB(10), 1);
}

-(GLKVector4)yellow {
  return GLKVector4Make(RGB(255), RGB(205), RGB(0), 1);
}

-(GLKVector4)orange {
  return GLKVector4Make(RGB(255), RGB(124), RGB(29), 1);
}

-(GLKVector4)white {
  return GLKVector4Make(RGB(57), RGB(201), RGB(190), 1);
}

-(GLKVector4)purple {
  return GLKVector4Make(RGB(145), RGB(50), RGB(155), 1);
}
#elif defined(THEME_IOS7)
-(GLKVector4)bg {
  return GLKVector4Make(RGB(240.0f), RGB(239.0f), RGB(236.0f), 1);
}

-(GLKVector4)hole {
  return GLKVector4Make(0.56f, 0.56f, 0.58f, 1);
}

-(GLKVector4)blue {
  return GLKVector4Make(0.0f, 0.49f, 0.96f, 1);
}

-(GLKVector4)red {
  return GLKVector4Make(1.0f, 0.22f, 0.22f, 1);
}

-(GLKVector4)green {
  return GLKVector4Make(0.27f, 0.85f, 0.46f, 1);
}

-(GLKVector4)yellow {
  return GLKVector4Make(1.0f, 0.79f, 0.28f, 1);
}

-(GLKVector4)orange {
  return GLKVector4Make(1.0f, 0.58f, 0.21f, 1);
}

-(GLKVector4)white {
  return GLKVector4Make(0.78f, 0.78f, 0.8f, 1);
}

-(GLKVector4)purple {
  return GLKVector4Make(0.35f, 0.35f, 0.81f, 1);
}
#endif

@end
