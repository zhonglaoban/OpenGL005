# 在iOS上如何使用OpenGL给图形添加一些变换
在上一篇中，我们了解了如何给图形给图形贴上一张图片（纹理）。那么本篇就来讲一下怎么让图形动起来吧（变换）。
- 创建一个变换矩阵
- 编写GLSL接收矩阵
- 修改矩阵的值

## 创建矩阵
我们用`GLKit`可以很容易的创建一个单位矩阵`GLKMatrix4Identity `，接着我们对这个矩阵做一些平移、缩放、旋转的处理。
我们添加3个UISlider来控制这些平移、缩放、旋转的值。代码如下：
```objc
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
```
创建单位矩阵，并应用这3个变量。
```objc
GLKMatrix4 transform = GLKMatrix4Identity;

transform = GLKMatrix4Translate(transform, _translationSlider.value, 0, 0);
transform = GLKMatrix4Scale(transform, _scaleSlider.value, _scaleSlider.value, 1);
transform = GLKMatrix4Rotate(transform, _rotateSlider.value, 0, 0, 1);
```

## 编写GLSL接收矩阵
有了矩阵的值后，我们需要修改片段着色器来接收这个值（`transform`），在`drawInRect`的时候将值传给片段着色器。
```c
attribute vec3 a_Position;
attribute vec2 a_TexCoord;

varying lowp vec2 TexCoord;

uniform mat4 transform;

void main(void) {
    gl_Position = transform * vec4(a_Position, 1.0);
    TexCoord = a_TexCoord;
}
```
修改管道（program）的代码，将值传给着色器。
```objc
- (void)setMat4:(const GLchar *)name value:(GLKMatrix4)mat {
    GLint location = glGetUniformLocation(_programHandle, name);
    glUniformMatrix4fv(location, 1, GL_FALSE, &mat.m00);
}
```

## 修改矩阵的值
我们可以修改3个`Slider`的值来看看效果。由于渲染的宽高是按窗口的大小来的，所以旋转的时候宽高会变，就成了一个四边形了。
![截图](https://upload-images.jianshu.io/upload_images/3277096-9728bdbaa3a6467d.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/375)

[Github地址](https://github.com/zhonglaoban/OpenGL005)，喜欢的点个赞。
