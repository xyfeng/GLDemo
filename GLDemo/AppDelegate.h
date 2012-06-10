//
//  AppDelegate.h
//  GLDemo
//
//  Created by XY Feng on 6/6/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) GLViewController *rootViewController;

@end
