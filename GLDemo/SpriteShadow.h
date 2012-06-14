//
//  SpriteShadow.h
//  GLDemo
//
//  Created by XY Feng on 6/13/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLCommon.h"

@class GLProgram;

@interface SpriteShadow : NSObject
@property(nonatomic, assign) GLuint texture;
- (void)draw;
@end
