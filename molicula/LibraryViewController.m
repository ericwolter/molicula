//
//  LibraryViewController.m
//  molicula
//
//  Created by Eric Wolter on 05/05/14.
//  Copyright (c) 2014 Eric Wolter. All rights reserved.
//

#import "LibraryViewController.h"
#import "GameView.h"

@interface LibraryViewController ()

@end

@implementation LibraryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 5;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return 10;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *identifier = @"Cell";
  
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
  
  UIImageView *solutionImageView = (UIImageView *)[cell viewWithTag:200];
  
  EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  [EAGLContext setCurrentContext:context];
  GameView *gameView = [[GameView alloc] initWithFrame:solutionImageView.bounds context:context];
  gameView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
  gameView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
  gameView.drawableMultisample = GLKViewDrawableMultisample4X;
  
  [gameView updateProjection:gameView.bounds.size];
  [gameView enableGrid];
  [gameView render];
  
  NSLog(@"render gameview");
  
  [solutionImageView setImage:[gameView snapshot]];
  
  return cell;
}

@end
