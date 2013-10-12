//
//  TranslateAnimation.h
//  molicula
//
//  Created by Eric Wolter on 10/12/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#import "BaseAnimation.h"

@interface TranslateAnimation : BaseAnimation

@property GLKVector2 end;
@property GLKVector2 velocity;

-(id)initWithMolecule:(Molecule *)molecule AndTranslation:(GLKVector2) translationVector;

@end
