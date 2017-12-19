//
//  SolutionLibrary.h
//  molicula
//
//  Created by Eric Wolter on 14/05/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  SolutionIsUnknown,
  SolutionIsBrandNew,
  SolutionIsNewVariation,
  SolutionIsDuplicate
} SolutionResult;

@interface SolutionLibrary : NSObject <DDiCloudSyncDelegate>

+ (SolutionLibrary *)sharedInstance;

@property NSDictionary *solutions;
@property NSDictionary *variations;
@property NSArray *sections;
@property NSString *currentSolution;
@property Boolean currentSolutionIsBrandNew;

- (void)readSolutions;
- (void)readSolutionsFromVersion1;
- (void)updateLocalSolutions;

- (NSArray*)blueMolecule;
- (NSArray*)greenMolecule;
- (NSArray*)redMolecule;
- (NSArray*)whiteMolecule;
- (NSArray*)yellowMolecule;

- (SolutionResult)recordSolution:(NSString *)proposedSolution WithMissingMolecule:(NSString *)color;
- (SolutionResult)checkSolutionForGrid:(NSString *)proposedSolution WithMissingMolecule:(NSString *)color;
- (NSString*)flipH:(NSString*)solution;
- (NSString*)flipV:(NSString*)solution;
- (NSString*)switchYellowOrange:(NSString *)solution;
- (NSString*)switchWhitePurple:(NSString *)solution;

- (NSArray*)mergeSolutionVersion1:(NSSet *)base with:(NSSet*)addition;
- (NSDictionary*)mergeSolutionVersion2:(NSDictionary*)base with:(NSDictionary*)addition;
@end

