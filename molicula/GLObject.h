//
//  GLObject.h
//  molicula
//
//  Created by Eric Wolter on 20.12.17.
//  Copyright © 2017 Eric Wolter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@protocol GLObject

@required
@property (nonatomic) GLKMatrix4 objectMatrix;
@property (nonatomic) GLKMatrix4 modelMatrix;
@property (nonatomic) GLKMatrix4 modelViewMatrix;
@property (nonatomic) GLKMatrix4 invertedModelViewMatrix;
@property (weak, nonatomic) id<GLObject> parent;
- (GLKMatrix4)calculateModelViewMatrix;

@end

@interface GLModel : NSObject <GLObject>

@end
