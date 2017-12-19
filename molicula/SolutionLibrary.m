//
//  SolutionLibrary.m
//  molicula
//
//  Created by Eric Wolter on 14/05/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "SolutionLibrary.h"
#import "Constants.h"
#import <Crashlytics/Crashlytics.h> // If using Answers with Crashlytics

@implementation SolutionLibrary

+ (SolutionLibrary *)sharedInstance
{
  //  Static local predicate must be initialized to 0
  static SolutionLibrary *sharedInstance = nil;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[SolutionLibrary alloc] init];
    sharedInstance.solutions = [NSDictionary dictionary];
    sharedInstance.variations = [NSDictionary dictionary];
    [sharedInstance readSolutions];
    [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                             selector:@selector(updateLocalSolutions)
                                                 name:kDDiCloudDidSyncNotification
                                               object:nil];
  });
  return sharedInstance;
}

- (void)readSolutions {
  MLog(@"[start]");
  MLog(@"building solution library");
  NSArray *solutionPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"txt" inDirectory:@"solutions"];
  
#ifndef MAKE_SCREENSHOT
  NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *immutableSolutionsInUserDefaults = [standardUserDefaults objectForKey:@"solutions2"];
  NSMutableDictionary *solutions = CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)(immutableSolutionsInUserDefaults), kCFPropertyListMutableContainersAndLeaves));
#else
  NSMutableDictionary *solutions = nil;
#endif

  if(!solutions) {
    solutions = [[NSMutableDictionary alloc] initWithCapacity:5];
  }
  /*
   solutions: {
     'y': {
       '000...000': {
         'user': []
       },
       '000...001': {
         ...
       }
     },
     'w': {
       ...
     }
   }
   */
  NSMutableDictionary *variations = [[NSMutableDictionary alloc] initWithCapacity:5];

  for (NSString *solutionPath in solutionPaths) {
    NSString *canonicalSolution = [NSString stringWithContentsOfFile:solutionPath encoding:NSASCIIStringEncoding error:NULL];
    
    NSString *color = [solutionPath lastPathComponent];
    color = [color substringWithRange:NSMakeRange(0, 1)];
    
    if(![solutions objectForKey:color]) {
      [solutions setValue:[NSMutableDictionary dictionary] forKey:color];
    }
    if(![variations objectForKey:color]) {
      [variations setValue:[NSMutableDictionary dictionary] forKey:color];
    }
    
    NSMutableDictionary *solutionsForColor = [solutions objectForKey:color];
    NSMutableDictionary *variationsForColor = [variations objectForKey:color];
    
    if (![solutionsForColor objectForKey:canonicalSolution]) {
      NSMutableDictionary *solution = [NSMutableDictionary dictionary];
      [solution setObject:[NSMutableArray array] forKey:@"user"];
      [solutionsForColor setObject:solution forKey:canonicalSolution];
    }
    
    if (![variationsForColor objectForKey:canonicalSolution]) {
      NSMutableArray *variations = [NSMutableArray array];
      [variations addObject:canonicalSolution];
      
      [variations addObject:[self flipH:canonicalSolution]];
      [variations addObject:[self flipV:canonicalSolution]];
      [variations addObject:[self flipV:[self flipH:canonicalSolution]]];
      
      [variations addObject:[self switchYellowOrange:canonicalSolution]];
      [variations addObject:[self switchYellowOrange:[self flipH:canonicalSolution]]];
      [variations addObject:[self switchYellowOrange:[self flipV:canonicalSolution]]];
      [variations addObject:[self switchYellowOrange:[self flipV:[self flipH:canonicalSolution]]]];
      
      [variations addObject:[self switchWhitePurple:canonicalSolution]];
      [variations addObject:[self switchWhitePurple:[self flipH:canonicalSolution]]];
      [variations addObject:[self switchWhitePurple:[self flipV:canonicalSolution]]];
      [variations addObject:[self switchWhitePurple:[self flipV:[self flipH:canonicalSolution]]]];
      
      [variations addObject:[self switchYellowOrange:[self switchWhitePurple:canonicalSolution]]];
      [variations addObject:[self switchYellowOrange:[self switchWhitePurple:[self flipH:canonicalSolution]]]];
      [variations addObject:[self switchYellowOrange:[self switchWhitePurple:[self flipV:canonicalSolution]]]];
      [variations addObject:[self switchYellowOrange:[self switchWhitePurple:[self flipV:[self flipH:canonicalSolution]]]]];
      
      [variationsForColor setObject:variations forKey:canonicalSolution];
    }
  }
  
  self.solutions = solutions;
  self.variations = variations;
  
  NSMutableArray *sections = [NSMutableArray array];
  for (NSString *color in self.solutions.allKeys) {
    NSString *factoryMethod;
    if([color isEqualToString:@"y"]) {
      factoryMethod = @"yellowMolecule";
    } else if ([color isEqualToString:@"w"]) {
      factoryMethod = @"whiteMolecule";
    } else if ([color isEqualToString:@"b"]) {
      factoryMethod = @"blueMolecule";
    } else if ([color isEqualToString:@"g"]) {
      factoryMethod = @"greenMolecule";
    } else if ([color isEqualToString:@"r"]) {
      factoryMethod = @"redMolecule";
    } else {
      factoryMethod = @"unknownMolecule";
    }
    
    NSDictionary *solutionsForColor = [self.solutions objectForKey:color];
    NSNumber *numberOfSolutions = [NSNumber numberWithInteger:solutionsForColor.count];
    NSDictionary *section = @{@"color": color, @"factory": factoryMethod, @"numberOfSolutions":numberOfSolutions};
    
    [sections addObject:section];
  }
  
  self.sections = [sections sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
    NSNumber *aNumberOfSolutions = [a objectForKey:@"numberOfSolutions"];
    NSNumber *bNumberOfSolutions = [b objectForKey:@"numberOfSolutions"];
    return [bNumberOfSolutions compare:aNumberOfSolutions];
  }];
  
  [self updateLocalSolutions];
}

- (void)updateLocalSolutions {
#ifndef MAKE_SCREENSHOT
  NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
  if ([standardUserDefaults objectForKey:@"solutions2"]) {
    self.solutions = (NSMutableDictionary *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)[standardUserDefaults objectForKey:@"solutions2"], kCFPropertyListMutableContainers));
  }
  [self readSolutionsFromVersion1];
#endif
}

- (void)readSolutionsFromVersion1 {
  
  NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
  NSArray *solutions = [standardUserDefaults arrayForKey:@"solutions"];
  if(solutions != nil) {
    MLog(@"found solutions from version 1");
    // determine missing color
    // check solution
    for (NSString *solution in solutions) {
      MLog(@"%@", solution);
      NSString *missingColor;
      if (![solution containsString:@"y"]) {
        missingColor = @"y";
      } else if (![solution containsString:@"o"]) {
        missingColor = @"o";
      } else if (![solution containsString:@"w"]) {
        missingColor = @"w";
      } else if (![solution containsString:@"p"]) {
        missingColor = @"p";
      } else if (![solution containsString:@"g"]) {
        missingColor = @"g";
      } else if (![solution containsString:@"b"]) {
        missingColor = @"b";
      } else if (![solution containsString:@"r"]) {
        missingColor = @"r";
      } else {
        continue;
      }
      MLog(@"%@",missingColor);
      [self recordSolution:solution WithMissingMolecule:missingColor];
    }
  } else {
    MLog(@"did not find any solutions from version 1");
  }
  // delete solutions
  [standardUserDefaults setValue:@[] forKey:@"solutions"];
}

- (NSArray*)blueMolecule {
  return [[self.solutions objectForKey:@"b"] allKeys];
}
- (NSArray*)greenMolecule {
  return [[self.solutions objectForKey:@"g"] allKeys];
}
- (NSArray*)redMolecule {
  return [[self.solutions objectForKey:@"r"] allKeys];
}
- (NSArray*)whiteMolecule {
  return [[self.solutions objectForKey:@"w"] allKeys];
}
- (NSArray*)yellowMolecule {
  return [[self.solutions objectForKey:@"y"] allKeys];
}

- (NSString*)switchWhitePurple:(NSString *)solution {
  NSUInteger len = [solution length];
  unichar buffer[len+1];
  
  [solution getCharacters:buffer range:NSMakeRange(0, len)];
  
  for (int i = 0; i < len; i++) {
    unichar c = buffer[i];
    if(c == 'w') {
      buffer[i] = 'p';
    } else if (c == 'p') {
      buffer[i] = 'w';
    }
  }
  
  return [NSString stringWithCharacters:buffer length:len];
}

- (NSString*)switchYellowOrange:(NSString *)solution {
  NSUInteger len = [solution length];
  unichar buffer[len+1];
  
  [solution getCharacters:buffer range:NSMakeRange(0, len)];
  
  for (int i = 0; i < len; i++) {
    unichar c = buffer[i];
    if(c == 'y') {
      buffer[i] = 'o';
    } else if (c == 'o') {
      buffer[i] = 'y';
    }
  }
  
  return [NSString stringWithCharacters:buffer length:len];
}

- (void)reverseUnicharBuffer:(unichar *)buffer fromStart:(NSUInteger)start toEnd:(NSUInteger)end {
  
  NSUInteger halfway = (end-start+1) / 2;
  for (NSUInteger h = 0; h < halfway; h++) {
    NSUInteger end_index = end - h;
    NSUInteger start_index = start + h;
    
    unichar swapElement = buffer[end_index];
    buffer[end_index] = buffer[start_index];
    buffer[start_index] = swapElement;
  }
  
}

- (void)reverseUnicharBufferIgnoringZeros:(unichar *)buffer fromStart:(NSUInteger)start toEnd:(NSUInteger)end {
  
//  NSLog(@"reverseUnicharBufferIgnoringZeros: %luu %luu", start, end);
//  
  BOOL hasEncounteredNonZero = NO;
  NSUInteger iterationEnd = end;
  for (NSUInteger i = start; i <= iterationEnd; i++) {
    unichar element = buffer[i];
//    NSLog(@"%luu: %C",i,element);
    if(element == '0') {
      if(!hasEncounteredNonZero) {
        start += 1;
      } else {
        end -= 1;
      }
    } else {
      hasEncounteredNonZero = YES;
    }
  }
  
  [self reverseUnicharBuffer:buffer fromStart:start toEnd:end];
}

- (NSString*)flipH:(NSString*)solution {
  NSUInteger len = [solution length];
  unichar buffer[len];
  
  [solution getCharacters:buffer range:NSMakeRange(0, len)];
  
  assert(len % GRID_WIDTH == 0);
  
  [self reverseUnicharBuffer:buffer fromStart:0 toEnd:len-1];
  
  for (int c = 0; c < GRID_WIDTH; c++) {
    NSUInteger column_start = c*(GRID_WIDTH - 1);
    NSUInteger column_end = column_start + GRID_HEIGHT - 1;
    
    [self reverseUnicharBufferIgnoringZeros:buffer fromStart:column_start toEnd:column_end];
  }
  
  return [NSString stringWithCharacters:buffer length:len];
}

- (NSString*)flipV:(NSString*)solution {
  NSUInteger len = [solution length];
  unichar buffer[len];
  
  assert(len % GRID_WIDTH == 0);
  
  [solution getCharacters:buffer range:NSMakeRange(0, len)];
  
  for (int c = 0; c < GRID_WIDTH; c++) {
    NSUInteger column_start = c*(GRID_WIDTH - 1);
    NSUInteger column_end = column_start + GRID_HEIGHT - 1;
    
    [self reverseUnicharBufferIgnoringZeros:buffer fromStart:column_start toEnd:column_end];
  }
  
  return [NSString stringWithCharacters:buffer length:len];
}

- (SolutionResult)recordSolution:(NSString *)proposedSolution WithMissingMolecule:(NSString *)color {
  SolutionResult result = [self checkSolutionForGrid:proposedSolution WithMissingMolecule:color];
  
  switch (result) {
    case SolutionIsBrandNew:
      MLog("Solution is brand new!");
      break;
    case SolutionIsNewVariation:
      MLog("Solution is new variation.");
      break;
    case SolutionIsDuplicate:
      MLog("Solution is duplicate");
      break;
    default:
      MLog("solution is unknown");
      break;
  }
  
  // sync to userdefaults
  NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
  [standardUserDefaults setObject:self.solutions forKey:@"solutions2"];
  [standardUserDefaults synchronize];
  MLog(@"Saving solution to user defaults");
  
  return result;
}

- (SolutionResult)checkSolutionForGrid:(NSString *)proposedSolution WithMissingMolecule:(NSString *)color {
  
  // some pieces have the same shape but different colors
  // the canonical solution however is only defined as a specific color
  // we change the non canonical color to the canonical color here
  // so that the correct solutions can be found
  if([color isEqualToString:@"o"]) {
    color = @"y";
  } else if ([color isEqualToString:@"p"]) {
    color = @"w";
  }
  NSDictionary *solutionsForColor = [self.solutions objectForKey:color];
  NSDictionary *variationsForColor = [self.variations objectForKey:color];
  
//  MLog(@"%@",proposedSolution);
  NSNumber *canonicalIndex = @0;
  for (NSString *canonicalSolution in solutionsForColor) {
//    MLog(@"%@",canonicalSolution);
    NSMutableDictionary *solution = [solutionsForColor objectForKey:canonicalSolution];
    
    NSArray *variations = [variationsForColor objectForKey:canonicalSolution];
    
    NSNumber *variationIndex = @0;
    for (NSString *variation in variations) {
      //MLog(@"%@",variation);
      if([variation isEqualToString:proposedSolution]) {
        
        NSMutableArray *userSolutions = [solution objectForKey:@"user"];
        
        NSUInteger previouslyFoundIndex = [userSolutions indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
          return [[obj objectForKey:@"solution"] isEqualToString:proposedSolution];
        }];
        
        if (previouslyFoundIndex == NSNotFound) {
          // the user has not found this variation before so we add it with timestamp
          // this allows solutions to be sorted by discovery order
          // TODO: Do we really need to store every found variation? Wouldn't a simple overall counter be enough?
          //       What do we gain by again storing all the variations and as a downside increase amount of synced data?
          NSMutableDictionary *userSolution = [NSMutableDictionary dictionaryWithDictionary:@{@"solution": proposedSolution, @"timestamp": [NSDate date], @"count": @1}];
          [userSolutions addObject:userSolution];
          
          if (userSolutions.count == 1) {
            [Answers logLevelEnd:[NSString stringWithFormat:@"%@;%@;%@", color, canonicalIndex, variationIndex]
                           score:@1
                         success:@YES
                customAttributes:@{
                                   @"solution": proposedSolution
                                   }];
            return SolutionIsBrandNew;
          }
          
          return SolutionIsNewVariation;
        } else {
          // the user has found this variation before
          // so we just increment the counter to remember how often this solutions has already been found
          NSMutableDictionary *userSolution = [userSolutions objectAtIndex:previouslyFoundIndex];
          NSUInteger count = [[userSolution objectForKey:@"count"] unsignedIntegerValue] + 1;
          [userSolution setObject:[NSNumber numberWithUnsignedInteger:count] forKey:@"count"];
          
          [Answers logLevelEnd:[NSString stringWithFormat:@"%@;%@;%@", color, canonicalIndex, variationIndex]
                         score:[NSNumber numberWithUnsignedInteger:count]
                       success:@YES
              customAttributes:@{
                                 @"solution": proposedSolution
                                 }];
          
          return SolutionIsDuplicate;
        }
      }
      variationIndex = @([variationIndex unsignedIntValue] + 1);
    }
    
    canonicalIndex = @([canonicalIndex unsignedIntValue] + 1);
  }

  // this should never happen, otherwise brute-force solution finder has an error
  return SolutionIsUnknown;
}

- (NSArray*)mergeSolutionVersion1:(NSSet *)base with:(NSSet*)addition {
  NSMutableSet *mergedSolutions = [NSMutableSet setWithSet:base];
  [mergedSolutions unionSet:addition];
  return [mergedSolutions allObjects];
}

- (NSDictionary*)mergeSolutionVersion2:(NSDictionary*)base with:(NSDictionary*)addition {
  NSMutableDictionary *mergedSolutions2 = [NSMutableDictionary dictionary];
  
  for (NSString *color in base) {
    NSMutableDictionary *mergedSolutionsForColor = [NSMutableDictionary dictionary];
    [mergedSolutions2 setObject:mergedSolutionsForColor forKey:color];
    
    NSDictionary *solutionsForColor = [base objectForKey:color];
    
    for (NSString *canonicalSolution in solutionsForColor) {
      NSMutableDictionary *mergedSolution = [NSMutableDictionary dictionary];
      [mergedSolutionsForColor setObject:mergedSolution forKey:canonicalSolution];
      NSMutableArray *mergedUserSolutions = [NSMutableArray array];
      [mergedSolution setObject:mergedUserSolutions forKey:@"user"];
      
      NSDictionary *solution = [solutionsForColor objectForKey:canonicalSolution];
      NSArray *userSolutions = [solution objectForKey:@"user"];
      
      for (NSDictionary *userSolution in userSolutions) {
        NSString *proposedSolution = userSolution[@"solution"];
        
        NSUInteger previouslyFoundIndex = [mergedUserSolutions indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
          return [[obj objectForKey:@"solution"] isEqualToString:proposedSolution];
        }];
        
        if (previouslyFoundIndex == NSNotFound) {
          [mergedUserSolutions addObject:userSolution.mutableCopy];
        } else {
          NSMutableDictionary *mergedUserSolution = [mergedUserSolutions objectAtIndex:previouslyFoundIndex];
          NSUInteger count = [[mergedUserSolution objectForKey:@"count"] unsignedIntegerValue] + 1;
          [mergedUserSolution setObject:[NSNumber numberWithUnsignedInteger:count] forKey:@"count"];
        }
      }
    }
  }
  
  for (NSString *color in addition) {
    NSMutableDictionary *mergedSolutionsForColor = [mergedSolutions2 objectForKey:color];
    NSDictionary *solutionsForColor = [addition objectForKey:color];
    
    for (NSString *canonicalSolution in solutionsForColor) {
      NSMutableDictionary *mergedSolution = [mergedSolutionsForColor objectForKey:canonicalSolution];
      NSMutableArray *mergedUserSolutions = [mergedSolution objectForKey:@"user"];
      
      NSDictionary *solution = [solutionsForColor objectForKey:canonicalSolution];
      NSArray *userSolutions = [solution objectForKey:@"user"];
      
      for (NSDictionary *userSolution in userSolutions) {
        NSString *proposedSolution = userSolution[@"solution"];
        
        NSUInteger previouslyFoundIndex = [mergedUserSolutions indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
          return [[obj objectForKey:@"solution"] isEqualToString:proposedSolution];
        }];
        
        if (previouslyFoundIndex == NSNotFound) {
          [mergedUserSolutions addObject:userSolution.copy];
        } else {
          NSMutableDictionary *mergedUserSolution = [mergedUserSolutions objectAtIndex:previouslyFoundIndex];
          NSUInteger count = [[mergedUserSolution objectForKey:@"count"] unsignedIntegerValue] + 1;
          [mergedUserSolution setObject:[NSNumber numberWithUnsignedInteger:count] forKey:@"count"];
        }
      }
    }
  }
  
  return mergedSolutions2;
}

- (NSDictionary*)mergedDefaultsForUpdatingCloud:(NSDictionary*)dictInCloud withLocalDefaults:(NSDictionary*)dict {
  
  NSMutableDictionary *mergedDict = dict.mutableCopy;
  
  // version 1
  // should not be needed once move to solutions2 format is done
//  NSSet *solutionsFromVersion1InLocal = [NSSet setWithArray:dict[@"solutions"]];
//  NSSet *solutionsFromVersion1InCloud = [NSSet setWithArray:dictInCloud[@"solutions"]];
//  mergedDict[@"solutions"] = [self mergeSolutionVersion1:solutionsFromVersion1InCloud with:solutionsFromVersion1InLocal];
  mergedDict[@"solutions"] = @[];
  
  // version 2
  NSDictionary *solutionsFromVersion2InLocal = [NSDictionary dictionaryWithDictionary:dict[@"solutions2"]];
  NSDictionary *solutionsFromVersion2InCloud = [NSDictionary dictionaryWithDictionary:dictInCloud[@"solutions2"]];
  mergedDict[@"solutions2"] = [self mergeSolutionVersion2:solutionsFromVersion2InCloud with:solutionsFromVersion2InLocal];
  
  return mergedDict;
}

- (NSDictionary*)mergedDefaultsForUpdatingLocalDefaults:(NSDictionary*)dict withCloud:(NSDictionary*)dictInCloud {

  NSMutableDictionary *mergedDict = dictInCloud.mutableCopy;
  
  // version 1
  NSSet *solutionsFromVersion1InLocal = [NSSet setWithArray:dict[@"solutions"]];
  NSSet *solutionsFromVersion1InCloud = [NSSet setWithArray:dictInCloud[@"solutions"]];
  mergedDict[@"solutions"] = [self mergeSolutionVersion1:solutionsFromVersion1InCloud with:solutionsFromVersion1InLocal];
  
  // version 2
  NSDictionary *solutionsFromVersion2InLocal = [NSDictionary dictionaryWithDictionary:dict[@"solutions2"]];
  NSDictionary *solutionsFromVersion2InCloud = [NSDictionary dictionaryWithDictionary:dictInCloud[@"solutions2"]];
  mergedDict[@"solutions2"] = [self mergeSolutionVersion2:solutionsFromVersion2InCloud with:solutionsFromVersion2InLocal];

  return mergedDict;
}

@end
