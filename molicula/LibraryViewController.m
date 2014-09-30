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

@interface LibraryViewController () {
  NSMutableDictionary *headerCache;
  NSMutableDictionary *solutionCache;
}

@property(strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation LibraryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    headerCache = [[NSMutableDictionary alloc] init];
    solutionCache = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    headerCache = [[NSMutableDictionary alloc] init];
    solutionCache = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
  self = [super initWithCollectionViewLayout:layout];
  if (self) {
    headerCache = [[NSMutableDictionary alloc] init];
    solutionCache = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (id)init {
  self = [super init];
  if (self) {
    headerCache = [[NSMutableDictionary alloc] init];
    solutionCache = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)viewDidLoad
{
  MLog("start");
  [super viewDidLoad];
  
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  
  if (!self.context) {
    NSLog(@"Failed to create ES context");
  }
  
  [self setupGL];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
  
  if(IS_IPAD) {
    flowLayout.itemSize = CGSizeMake(188.0f, 188.f);
    flowLayout.headerReferenceSize = CGSizeMake(100.0f, 100.0f);
  } else {
    flowLayout.itemSize = CGSizeMake(106.0f, 106.f);
    flowLayout.headerReferenceSize = CGSizeMake(50.0f, 50.0f);
  }
}

- (void)didReceiveMemoryWarning {
  MLog("start");
  [super didReceiveMemoryWarning];
  
  if ([self isViewLoaded] && ([[self view] window] == nil)) {
    self.view = nil;
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
      [EAGLContext setCurrentContext:nil];
    }
    
    self.context = nil;
  }
  
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  MLog(@"start");
  [self tearDownGL];
  
  if ([EAGLContext currentContext] == self.context) {
    [EAGLContext setCurrentContext:nil];
  }
}

- (void)setupGL
{
  MLog(@"start");
  [EAGLContext setCurrentContext:self.context];
}

- (void)tearDownGL
{
  MLog(@"start");
  MLog(@"%@", self.context);
  [EAGLContext setCurrentContext:self.context];
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
    //    NSLog(@"%d: (%d,%d): %@", i, row, col, identifier);
    
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
  solutionImageView.frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
  
  NSString *sectionColor = [[[SolutionLibrary sharedInstance].sections objectAtIndex:indexPath.section] objectForKey:@"color"];
  NSDictionary *solutionsForColor = [[SolutionLibrary sharedInstance].solutions objectForKey:sectionColor];
  NSString *canonicalString = [[solutionsForColor allKeys] objectAtIndex:indexPath.row];
  if(![solutionCache objectForKey:canonicalString]) {
    GameView *gameView = [[GameView alloc] initWithFrame:solutionImageView.bounds context:self.context];
    
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular
        && self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
      [gameView setScaling:1.0f];
    } else {
      [gameView setScaling:0.5f];
    }
    
    gameView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    gameView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    gameView.drawableMultisample = GLKViewDrawableMultisample4X;
    
    [gameView updateProjection:gameView.bounds.size];
    
    NSDictionary *solution = [solutionsForColor objectForKey:canonicalString];
    NSString *userSolution = solution[@"user"];
    if(userSolution) {
      NSDictionary *solutionMolecules = [self generateMoleculePointsFromSolution:userSolution];
      [self addSolutionMolecules:solutionMolecules toGame:gameView];
    } else {
      [gameView enableGrid];
    }
    
    solutionCache[canonicalString] = [gameView snapshot];
  }
  
  solutionImageView.image = solutionCache[canonicalString];
  
  return cell;
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
      GameView *gameView = [[GameView alloc] initWithFrame:moleculeImageView.bounds context:self.context];
      if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular
          && self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        [gameView setScaling:1.0f];
      } else {
        [gameView setScaling:0.5f];
      }
      gameView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
      gameView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
      gameView.drawableMultisample = GLKViewDrawableMultisample4X;
      
      [gameView updateProjection:gameView.bounds.size];
      
      SEL moleculeFactoryFunction = NSSelectorFromString(factoryMethod);
      Molecule *molecule = [MoleculeFactory performSelector:moleculeFactoryFunction];
      [gameView addMolecule:molecule];
      
      headerCache[factoryMethod] = [gameView snapshot];
    }
    
    headerView.MissingMoleculeImage.image = headerCache[factoryMethod];
    reusableview = headerView;
  }
  
  return reusableview;
}

@end
