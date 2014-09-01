//
//  ViewController.m
//  TestDraw
//
//  Created by 子初 on 14-8-15.
//  Copyright (c) 2014年 子初. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    GLuint _program;
    GLfloat _Rotation;
}

@end

GLfloat squareVertex[48]=
{
    0.5f,0.5f,-0.9f,       0.0f,0.0f,1.0f,     1.0f,1.0f,
    -0.5f,0.5f,-0.9f,      0.0f,0.0f,1.0f,     0.0f,1.0f,
    0.5f,-0.5f,-0.9f,      0.0f,0.0f,1.0f,     1.0f,0.0f,
    0.5f,-0.5f,-0.9f,      0.0f,0.0f,1.0f,     1.0f,0.0f,
    -0.5f,0.5f,-0.9f,      0.0f,0.0f,1.0f,     0.0f,1.0f,
    -0.5f,-0.5f,-0.9f,      0.0f,0.0f,1.0f,     0.0f,0.0f,
    
};

@implementation ViewController
// 补足定义
@synthesize context;
@synthesize effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // 设置内容
    self.context=[[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:context];
    glEnable(GL_DEPTH_TEST);
    
    // 设置场景
    self.effect = [[[GLKBaseEffect alloc] init] autorelease];
    
    self.effect.light0.enabled = GL_TRUE;
    // 设置光源颜色，白光
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    // 顶点索引
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertex), squareVertex, GL_STATIC_DRAW);
    // 顶点缓冲
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,4*8,(char *)NULL+0);
    
    // 法向量
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE,4*8,(char *)NULL+12);
    
    // 纹理
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE,4*8,(char *)NULL+24);
    
    // 加载shader
    NSString * vectFile = [[NSBundle mainBundle] pathForResource:@"v" ofType:@"shader"];
    NSString * fragFile = [[NSBundle mainBundle] pathForResource:@"f" ofType:@"shader"];
    
    _program = [self loadShaders:vectFile frag:fragFile];
    
    GLint params=0;
    
    // 检测是否有效
    glGetProgramiv(_program, GL_LINK_STATUS, &params);
    if (params == 1) {
        //int i=1;
        // 绑定参数
        glBindAttribLocation(_program, 0, "position");
        glBindAttribLocation(_program, 3, "texCoord");
        glLinkProgram(_program);
        
        glUseProgram(_program);
        
        // 激活纹理0号单元
        GLuint colorMap = glGetUniformLocation(_program, "colorMap");
        glUniform1i(colorMap, 0);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 更新
- (void)update
{
    // 设置y轴比例
    CGSize size = self.view.bounds.size;
    float aspect = fabsf(size.width/size.height);
    GLKMatrix4 projectMatrix = GLKMatrix4Identity;
    
    // 正交投影，1:1
    //projectMatrix = GLKMatrix4Scale(projectMatrix, 1.0f, aspect, 1.0f);
    
    // 透视投影，视角，纵横比，近平面，远平面
    projectMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(70.0), aspect, 0.1f, 10.0f);
    self.effect.transform.projectionMatrix = projectMatrix;
    
    // 模型变换
    GLKMatrix4 modelMatrix  = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    self.effect.transform.modelviewMatrix = modelMatrix;
    
    // 纹理
    NSString * strFilePath = [[NSBundle mainBundle] pathForResource:@"xin" ofType:@"jpg"];
    
    // 设置纹理从左下角开始
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft,nil];
    
    GLKTextureInfo *texuInfo = [GLKTextureLoader textureWithContentsOfFile:strFilePath options:options error:nil];
    
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = texuInfo.name;
    
    // 更新shader转化矩阵
    GLint mat = glGetUniformLocation(_program, "modelProjectMatrix");
    
    // 注意先平移和先旋转的区别
    
    // 旋转
    modelMatrix  = GLKMatrix4Rotate(modelMatrix, _Rotation, 0.0f, 0.0f,1.0f);
    
    // 偏移位置
    modelMatrix  = GLKMatrix4Translate(modelMatrix, 1.0f, 1.0f, -1.0f);

    
    GLKMatrix4 modelProjedtMatrixShader = GLKMatrix4Multiply(projectMatrix, modelMatrix);
 
    glUniformMatrix4fv(mat, 1, GL_FALSE, modelProjedtMatrixShader.m);
    
    _Rotation += self.timeSinceLastUpdate * 0.5f;
}

// 渲染
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    // sharder绘制
    glUseProgram(_program);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

// 链接程序
- (GLint)loadShaders:(NSString *)vert frag:(NSString *)frag
{
    GLuint vectShader,fragShader;
    GLuint pprogram = glCreateProgram();
    [self compileShader:&vectShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(pprogram, vectShader);
    glAttachShader(pprogram, fragShader);
    
    glLinkProgram(pprogram);
    return pprogram;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString*)file
{
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    
    glCompileShader(*shader);
    
}
@end
