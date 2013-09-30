//
//  GameViewController_iPad.m
//  molicula
//
//  Created by Eric Wolter on 9/30/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "GameViewController_iPad.h"
#import "Controls_iPad.h"

@interface GameViewController_iPad () {
  Controls_iPad *tutorial;
}

@end

@implementation GameViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      tutorial = [[Controls_iPad alloc] init];
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

- (void)render {
  [super render];
  
  if(pointerTouch != nil) {
    CGPoint point = [self touchPointToGLPoint:[pointerTouch locationInView:self.view]];
    [tutorial setPosition:GLKVector2Make(point.x, point.y)];
    self.effect.constantColor = activeMolecule.color;
    [tutorial render:self.effect andRotationInProgress:isRotationInProgress andMirroringInProgress:isMirroringInProgress];
  }
}

@end
