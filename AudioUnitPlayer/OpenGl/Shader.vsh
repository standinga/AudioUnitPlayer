attribute float vPosition;
attribute float vValue;

varying vec2 texCoordVarying;

void main()
{
    gl_Position = vec4(vPosition, vValue, 0, 1);
}
