//v.shader

attribute vec4 position;
attribute vec2 texCoord;
// dingyishuchu
varying lowp vec2 coord;
// zhuanhuanjuzhen
uniform mat4 modelProjectMatrix;

void main()
{
    coord = texCoord;
    gl_Position = modelProjectMatrix * position;
}