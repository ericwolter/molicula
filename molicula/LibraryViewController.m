//
//  LibraryViewController.m
//  molicula
//
//  Created by Eric Wolter on 05/05/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "LibraryViewController.h"
#import "GameView.h"
#import "SolutionCollectionHeaderView.h"
#import "SolutionLibrary.h"
#import "MoleculeFactory.h"
#import "GameViewController.h"
#import "ColorTheme.h"

@interface LibraryViewController () {
  NSMutableDictionary *headerCache;
  NSMutableDictionary *solutionCache;
}

- (void)setupGL;

@end

@implementation LibraryViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self setup];
  }
  return self;
}

-(void)setup
{
  headerCache = [[NSMutableDictionary alloc] init];
  solutionCache = [[NSMutableDictionary alloc] init];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupGL];
}

- (void)unlock {
  [self setupGL];
  
  [solutionCache removeAllObjects];
  [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  
  if ([self isViewLoaded] && ([[self view] window] == nil)) {
    self.view = nil;
  }
}

- (void)setupGL
{
  [EAGLContext setCurrentContext:MyAppDelegate.context];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return [SolutionLibrary sharedInstance].sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  NSNumber *numberOfSolutions = [[[SolutionLibrary sharedInstance].sections objectAtIndex:section] objectForKey:@"numberOfSolutions"];
  return [numberOfSolutions integerValue];
}

- (NSDictionary*)generateMoleculePointsFromSolution:(NSString *)solution {
  
  int row = 0;
  int col = 0;
  NSMutableDictionary *solutionMolecules = [[NSMutableDictionary alloc] init];
  for (uint i = 0; i < [solution length]; ++i) {
    NSString *identifier = [solution substringWithRange:NSMakeRange(i, 1)];
    row = i / GRID_HEIGHT;
    col = i % GRID_HEIGHT - 1;
    
    if ([identifier isEqualToString:@"0"]) {
      continue;
    }
    
    if (![solutionMolecules objectForKey:identifier]) {
      [solutionMolecules setObject:[NSMutableArray arrayWithCapacity:5] forKey:identifier];
    }
    NSMutableArray *points = [solutionMolecules objectForKey:identifier];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(row, col)]];
  }
  
  return solutionMolecules;
}

- (void)addSolutionMolecules:(NSDictionary*)solutionMolecules toGame:(GameView*)gameView {
  
  [gameView enableGrid];
  
  for (id key in solutionMolecules) {
    CGPoint points[5];
    for (uint i=0; i < 5; ++i) {
      NSValue *value = [[solutionMolecules objectForKey:key] objectAtIndex:i];
      points[i] = [value CGPointValue];
    }
    
    Molecule *m = [[Molecule alloc] initWithPoints:points andIdentifier:key];
    [gameView addMolecule:m];
    
    Hole *h = [[gameView.grid.holes objectAtIndex:points[0].x] objectAtIndex:points[0].y + 1];
    Atom *a = [[m.atoms objectAtIndex:points[0].x] objectAtIndex:points[0].y + 1];
    
    GLKVector2 holeWorldPosition = [gameView.grid getHoleWorldCoordinates:h];
    GLKVector2 atomWorldPosition = [m getAtomPositionInWorld:a];
    
    GLKVector2 offset = GLKVector2Subtract(holeWorldPosition, atomWorldPosition);
    [m translate:offset];
  }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *identifier = @"SolutionCell";
  
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
  
  UIImageView *solutionImageView = (UIImageView *)[cell viewWithTag:100];
  NSString *sectionColor = [[[SolutionLibrary sharedInstance].sections objectAtIndex:indexPath.section] objectForKey:@"color"];
  NSDictionary *solutionsForColor = [[SolutionLibrary sharedInstance].solutions objectForKey:sectionColor];
  NSString *canonicalString = [[solutionsForColor keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    NSDate *timestamp1 = [[[obj1 objectForKey:@"user"] firstObject] objectForKey:@"timestamp"];
    NSDate *timestamp2 = [[[obj2 objectForKey:@"user"] firstObject] objectForKey:@"timestamp"];
    
    if (timestamp1 && timestamp2) {
      return [timestamp1 compare:timestamp2];
    } else if (timestamp1) {
      return NSOrderedAscending;
    } else if (timestamp2) {
      return NSOrderedDescending;
    } else {
      return NSOrderedSame;
    }
  }] objectAtIndex:indexPath.row];
  NSDictionary *solution = [solutionsForColor objectForKey:canonicalString];
  NSArray *userSolutions = [solution objectForKey:@"user"];
  NSString *userSolution = [[userSolutions firstObject] objectForKey:@"solution"];
  
  if(![solutionCache objectForKey:canonicalString]) {
    GameView *gameView = [[GameView alloc] initWithFrame:solutionImageView.bounds context:MyAppDelegate.context];
    [gameView setScaling:gameView.bounds.size.width/cell.bounds.size.width/2.0f];
    [gameView updateProjection:gameView.bounds.size];
    
    if(userSolution) {
      NSDictionary *solutionMolecules = [self generateMoleculePointsFromSolution:userSolution];
      [self addSolutionMolecules:solutionMolecules toGame:gameView];
    } else {
      [gameView enableGrid];
    }
    
    solutionCache[canonicalString] = [gameView snapshot];
  }
  
  solutionImageView.image = solutionCache[canonicalString];
  [self setDifferenceView:cell forSolutionOnGrid:[SolutionLibrary sharedInstance].currentSolution andSolutionInLibrary:userSolution];
  
  return cell;
}

- (void)setDifferenceView:(UICollectionViewCell *)cell forSolutionOnGrid:(NSString *)gridSolution andSolutionInLibrary:(NSString *)librarySolution {
  UIView *stackViewContainer = [cell viewWithTag:200];
  if (!librarySolution) {
    stackViewContainer.hidden = YES;
    return;
  } else {
    stackViewContainer.hidden = NO;
  }
  
  SolutionLibrary *library = [SolutionLibrary sharedInstance];
  
  UIStackView *stackView = [stackViewContainer viewWithTag:210];
  for (UIImageView *solutionDifferenceView in stackView.subviews) {
    solutionDifferenceView.hidden = YES;
  }
  
  if([gridSolution isEqualToString:librarySolution]) {
    if([library currentSolutionIsBrandNew]) {
      [stackView viewWithTag:211].hidden = NO;
    } else {
      [stackView viewWithTag:212].hidden = NO;
    }
  } else if([gridSolution isEqualToString:[library flipH:librarySolution]]) {
    [stackView viewWithTag:213].hidden = NO;
  } else if([gridSolution isEqualToString:[library flipV:librarySolution]]) {
    [stackView viewWithTag:214].hidden = NO;
  } else if([gridSolution isEqualToString:[library flipV:[library flipH:librarySolution]]]) {
    [stackView viewWithTag:213].hidden = NO;
    [stackView viewWithTag:214].hidden = NO;
  } else if([gridSolution isEqualToString:[library switchYellowOrange:librarySolution]]) {
    [stackView viewWithTag:215].hidden = NO;
  } else if([gridSolution isEqualToString:[library switchYellowOrange:[library flipH:librarySolution]]]) {
    [stackView viewWithTag:213].hidden = NO;
    [stackView viewWithTag:215].hidden = NO;
  } else if([gridSolution isEqualToString:[library switchYellowOrange:[library flipV:librarySolution]]]) {
    [stackView viewWithTag:214].hidden = NO;
    [stackView viewWithTag:215].hidden = NO;
  } else if([gridSolution isEqualToString:[library switchYellowOrange:[library flipV:[library flipH:librarySolution]]]]) {
    [stackView viewWithTag:213].hidden = NO;
    [stackView viewWithTag:214].hidden = NO;
    [stackView viewWithTag:215].hidden = NO;
  } else if([gridSolution isEqualToString:[library switchWhitePurple:librarySolution]]) {
    [stackView viewWithTag:216].hidden = NO;
  } else if([gridSolution isEqualToString:[library switchWhitePurple:[library flipH:librarySolution]]]) {
    [stackView viewWithTag:213].hidden = NO;
    [stackView viewWithTag:216].hidden = NO;
  } else if([gridSolution isEqualToString:[library switchWhitePurple:[library flipV:librarySolution]]]) {
    [stackView viewWithTag:214].hidden = NO;
    [stackView viewWithTag:216].hidden = NO;
  } else if([gridSolution isEqualToString:[library switchWhitePurple:[library flipV:[library flipH:librarySolution]]]]) {
    [stackView viewWithTag:213].hidden = NO;
    [stackView viewWithTag:214].hidden = NO;
    [stackView viewWithTag:216].hidden = NO;
  } else if([gridSolution isEqualToString:[library switchYellowOrange:[library switchWhitePurple:librarySolution]]]) {
    [stackView viewWithTag:215].hidden = NO;
    [stackView viewWithTag:216].hidden = NO;
  } else if([gridSolution isEqualToString:[library switchYellowOrange:[library switchWhitePurple:[library flipH:librarySolution]]]]) {
    [stackView viewWithTag:213].hidden = NO;
    [stackView viewWithTag:215].hidden = NO;
    [stackView viewWithTag:216].hidden = NO;
  } else if([gridSolution isEqualToString:[library switchYellowOrange:[library switchWhitePurple:[library flipV:librarySolution]]]]) {
    [stackView viewWithTag:214].hidden = NO;
    [stackView viewWithTag:215].hidden = NO;
    [stackView viewWithTag:216].hidden = NO;
  } else if([gridSolution isEqualToString:[library switchYellowOrange:[library switchWhitePurple:[library flipV:[library flipH:librarySolution]]]]]) {
    [stackView viewWithTag:213].hidden = NO;
    [stackView viewWithTag:214].hidden = NO;
    [stackView viewWithTag:215].hidden = NO;
    [stackView viewWithTag:216].hidden = NO;
  } else {
    stackViewContainer.hidden = YES;
  }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  UICollectionReusableView *reusableview = nil;
  
  if (kind == UICollectionElementKindSectionHeader) {
    SolutionCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    
    UIImageView *moleculeImageView = headerView.MissingMoleculeImage;
    moleculeImageView.frame = CGRectMake(0, 0, headerView.bounds.size.width, headerView.bounds.size.height);
    
    NSString *factoryMethod = [[[SolutionLibrary sharedInstance].sections objectAtIndex:indexPath.section] objectForKey:@"factory"];
    if(![headerCache objectForKey:factoryMethod]) {
      GameView *gameView = [[GameView alloc] initWithFrame:moleculeImageView.bounds context:MyAppDelegate.context];
      [gameView enableGrid];
      [gameView setScaling:0.8f];
      [gameView updateProjection:gameView.bounds.size];
      
      if([factoryMethod isEqualToString:@"yellowMolecule"]) {
        SEL moleculeFactoryFunction1 = NSSelectorFromString(factoryMethod);
        SEL moleculeFactoryFunction2 = NSSelectorFromString(@"orangeMolecule");
        
        Molecule *molecule1 = [MoleculeFactory performSelector:moleculeFactoryFunction1];
        Molecule *molecule2 = [MoleculeFactory performSelector:moleculeFactoryFunction2];
        [gameView addMolecule:molecule1];
        [gameView addMolecule:molecule2];
        
        Hole *h = [[gameView.grid.holes objectAtIndex:0] objectAtIndex:3];
        GLKVector2 holeWorldPosition = [gameView.grid getHoleWorldCoordinates:h];
        
        [molecule1 translate:GLKVector2Make(holeWorldPosition.x, 0.0f)];
        [molecule2 translate:GLKVector2Make(-holeWorldPosition.x, 0.0f)];
      } else if ([factoryMethod isEqualToString:@"whiteMolecule"]) {
        SEL moleculeFactoryFunction1 = NSSelectorFromString(factoryMethod);
        SEL moleculeFactoryFunction2 = NSSelectorFromString(@"purpleMolecule");
        
        Molecule *molecule1 = [MoleculeFactory performSelector:moleculeFactoryFunction1];
        Molecule *molecule2 = [MoleculeFactory performSelector:moleculeFactoryFunction2];
        [gameView addMolecule:molecule1];
        [gameView addMolecule:molecule2];
        
        Hole *h = [[gameView.grid.holes objectAtIndex:0] objectAtIndex:3];
        GLKVector2 holeWorldPosition = [gameView.grid getHoleWorldCoordinates:h];
        
        [molecule1 translate:GLKVector2Make(holeWorldPosition.x, 0.0f)];
        [molecule2 translate:GLKVector2Make(-holeWorldPosition.x, 0.0f)];
      } else {
        SEL moleculeFactoryFunction = NSSelectorFromString(factoryMethod);
        
        Molecule *molecule1 = [MoleculeFactory performSelector:moleculeFactoryFunction];
        [gameView addMolecule:molecule1];
      }
      
      [gameView disableGrid];
      headerCache[factoryMethod] = [gameView snapshot];
      
    }
    
    headerView.MissingMoleculeImage.image = headerCache[factoryMethod];
    reusableview = headerView;
  }
  
  return reusableview;
}

@end
