//
//  SolutionLibrary.m
//  molicula
//
//  Created by Eric Wolter on 14/05/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "SolutionLibrary.h"
#import "Constants.h"

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
    
  });
  return sharedInstance;
}

- (void)readSolutions {
  NSArray *solutionPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"txt" inDirectory:@"solutions"];
  
  NSMutableDictionary *solutions = [[NSMutableDictionary alloc] initWithCapacity:5];
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

- (SolutionResult)checkSolutionForGrid:(NSString *)proposedSolution WithMissingMolecule:(NSString *)color {
  if([color isEqualToString:@"o"]) {
    color = @"y";
  } else if ([color isEqualToString:@"p"]) {
    color = @"w";
  }
  NSDictionary *solutionsForColor = [self.solutions objectForKey:color];
  NSDictionary *variationsForColor = [self.variations objectForKey:color];
  
  MLog(@"%@",proposedSolution);
  for (NSString *canonicalSolution in solutionsForColor) {
    MLog(@"%@",canonicalSolution);
    NSMutableDictionary *solution = [solutionsForColor objectForKey:canonicalSolution];
    
    NSArray *variations = [variationsForColor objectForKey:canonicalSolution];
    
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
        } else {
          // the user has found this variation before
          // so we just increment the counter to remember how often this solutions has already been found
          NSMutableDictionary *userSolution = [userSolutions objectAtIndex:previouslyFoundIndex];
          NSUInteger count = [[userSolution objectForKey:@"count"] unsignedIntegerValue] + 1;
          [userSolution setObject:[NSNumber numberWithUnsignedInteger:count] forKey:@"count"];
        }
        
        return SolutionIsDuplicate;
      }
    }
  }
  
  /*
@{
   'y': @{
           'canonicalSolution': @{ 'variations': @[], 'user': 'proposedSolution'},
           ...
         },
   ...
 }
*/

/*
@{
   'y': @{
           'canonicalSolution': @{ 'variations': @[], 'user': @[ @{ 'solution': @"", 'timestamp': Date, 'count': 1 } ]},
           ...
         },
   ...
 }
*/
  // this should never happen, otherwise brute-force solution finder has an error
  return SolutionIsNew;
}

@end
