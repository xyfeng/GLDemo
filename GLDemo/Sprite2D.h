//
//  Sprite2D.h
//  GLDemo
//
//  Created by XY Feng on 6/8/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLCommon.h"

@class GLProgram, GLTexture;

@interface Sprite2D : NSObject
@property(nonatomic, assign) Vertex3D position;
@property(nonatomic, assign) CGSize   contentSize;
- (id)initWithFileName:(NSString *)fileName;
- (void)update;
- (void)draw;
@end
