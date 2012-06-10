//
//  Sprite3D.h
//  GLDemo
//
//  Created by XY Feng on 6/8/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLCommon.h"
enum {
    SPRITE_ALIGN_LEFT = -1,
    SPRITE_ALIGN_CENTER = 0,
    SPRITE_ALIGN_RIGHT = 1,
};
typedef NSInteger SpriteAlignment;

@class GLProgram;

@interface Sprite3D : NSObject
@property(nonatomic, assign) Vertex3D position;
@property(nonatomic, assign) Color    color;
@property(nonatomic, assign) CGSize   contentSize;
@property(nonatomic, assign) CGFloat  angle;

- (id)initWithContentSize:(CGSize)contentSize Alignment:(SpriteAlignment)alignment;
- (void)update;
- (void)draw;

@end
