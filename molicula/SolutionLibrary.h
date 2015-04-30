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
  SolutionIsNew,
  SolutionIsDuplicate
} SolutionResult;

@interface SolutionLibrary : NSObject <DDiCloudSyncDelegate>

+ (SolutionLibrary *)sharedInstance;

@property NSDictionary *solutions;
@property NSDictionary *variations;
@property NSArray *sections;

- (void)readSolutions;
- (void)readSolutionsFormVersion1;

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

@end

