//f.shader

varying lowp vec2 coord;
uniform sampler2D colorMap;

void main()
{
    //gl_FragColor = vec4(1,1,0,1);
    gl_FragColor = texture2D(colorMap,coord.st);
}