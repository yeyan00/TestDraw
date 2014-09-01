//
//  ViewController.h
//  TestDraw
//
//  Created by 子初 on 14-8-15.
//  Copyright (c) 2014年 子初. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface ViewController : GLKViewController
@property(strong,nonatomic)EAGLContext * context;
@property(strong,nonatomic)GLKBaseEffect * effect;

- (GLint)loadShaders:(NSString *)vert frag:(NSString *)frag;
- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString*)file;
@end
