//
//  LibraryViewController.h
//  molicula
//
//  Created by Eric Wolter on 05/05/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GameView;
@class PurchaseViewController;

@interface LibraryViewController : UICollectionViewController

@property PurchaseViewController *purchaseController;

- (NSDictionary*)generateMoleculePointsFromSolution:(NSString *)solution;
- (void)addSolutionMolecules:(NSDictionary*)solutionMolecules toGame:(GameView*)gameView;
- (void)unlock;
- (void)setDifferenceView:(UICollectionViewCell *)cell forSolutionOnGrid:(NSString *)gridSolution andSolutionInLibrary:(NSString *)librarySolution;

@end
