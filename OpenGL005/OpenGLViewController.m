//
//  OpenGLViewController.m
//  OpenGL005
//
//  Created by 钟凡 on 2020/12/11.
//

#import "OpenGLViewController.h"
#import "ZFShader.h"

@interface OpenGLViewController ()

@property (nonatomic, assign) GLuint rectangleVAO;

@property (nonatomic, strong) ZFShader *rectangleShader;
@property (nonatomic, strong) GLKTextureInfo *flowerTexture;

@property (nonatomic, strong) UISlider *translationSlider;
@property (nonatomic, strong) UISlider *scaleSlider;
@property (nonatomic, strong) UISlider *rotateSlider;

@end

@implementation OpenGLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *glView = (GLKView *)self.view;
    glView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:glView.context];
    
    [self setupShader];
    [self setupVAO];
    [self setupTexture];
    [self setupSliders];
}
- (void)setupShader {
    _rectangleShader = [[ZFShader alloc] initWithVertexShader:@"rectangle.vs" fragmentShader:@"rectangle.fs"];
}
- (void)setupVAO {
    GLfloat rectangleVertices[] = {
        //position  texcoord
        -0.4,  0.2, 0.0, 0.0, 0.0,
        -0.4, -0.2, 0.0, 0.0, 1.0,
         0.4, -0.2, 0.0, 1.0, 1.0,
         0.4,  0.2, 0.0, 1.0, 0.0,
    };
    glGenBuffers(1, &_rectangleVAO);
    glBindBuffer(GL_ARRAY_BUFFER, _rectangleVAO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(rectangleVertices), rectangleVertices, GL_STATIC_DRAW);
}
- (void)setupTexture {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flower" ofType:@"jpg"];
    NSError *theError;
    _flowerTexture = [GLKTextureLoader textureWithContentsOfFile:filePath options:nil error:&theError];
}
- (void)setupSliders {
    CGSize size = self.view.bounds.size;
    _translationSlider = [[UISlider alloc] initWithFrame:CGRectMake(16, size.height - 140, size.width - 32, 16)];
    _scaleSlider = [[UISlider alloc] initWithFrame:CGRectMake(16, size.height - 100, size.width - 32, 16)];
    _rotateSlider = [[UISlider alloc] initWithFrame:CGRectMake(16, size.height - 60, size.width - 32, 16)];
    
    _translationSlider.minimumValue = 0;
    _translationSlider.maximumValue = 1;
    _scaleSlider.minimumValue = 1;
    _scaleSlider.maximumValue = 2;
    _rotateSlider.minimumValue = 0;
    _rotateSlider.maximumValue = 3.14;
    
    [self.view addSubview:_translationSlider];
    [self.view addSubview:_scaleSlider];
    [self.view addSubview:_rotateSlider];
}
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    GLKView *glView = (GLKView *)self.view;
    [EAGLContext setCurrentContext:glView.context];
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [_rectangleShader prepareToDraw];
    
    GLKMatrix4 transform = GLKMatrix4Identity;

    transform = GLKMatrix4Translate(transform, _translationSlider.value, 0, 0);
    transform = GLKMatrix4Scale(transform, _scaleSlider.value, _scaleSlider.value, 1);
    transform = GLKMatrix4Rotate(transform, _rotateSlider.value, 0, 0, 1);
    
    [_rectangleShader setMat4:"transform" value:transform];
    
    glBindBuffer(GL_ARRAY_BUFFER, _rectangleVAO);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
    
    glActiveTexture(_flowerTexture.target);
    glBindTexture(_flowerTexture.target, _flowerTexture.name);
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}
@end
