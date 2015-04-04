//
//  SolutionLibrary.h
//  molicula
//
//  Created by Eric Wolter on 14/05/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  SolutionIsNew,
  SolutionIsKnown,
  SolutionIsDuplicate
} SolutionResult;

@interface SolutionLibrary : NSObject

+ (SolutionLibrary *)sharedInstance;

@property NSDictionary *solutions;
@property NSArray *sections;

- (void)readSolutions;

- (NSArray*)blueMolecule;
- (NSArray*)greenMolecule;
- (NSArray*)redMolecule;
- (NSArray*)whiteMolecule;
- (NSArray*)yellowMolecule;

- (SolutionResult)checkSolutionForGrid:(NSString *)proposedSolution WithMissingMolecule:(NSString *)color;
- (NSString*)flipH:(NSString*)solution;
- (NSString*)flipV:(NSString*)solution;
- (NSString*)switchYellowOrange:(NSString *)solution;
- (NSString*)switchWhitePurple:(NSString *)solution;

@end

