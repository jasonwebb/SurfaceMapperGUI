uniform sampler2D tex0;
uniform sampler2D tex1;
uniform sampler2D tex2;
uniform sampler2D tex3;

void main(void)
{
    vec2 st = gl_TexCoord[0].st;
    vec4 color0 = texture2D(tex0, st);
    vec4 color1 = texture2D(tex1, st);
    vec4 color2 = texture2D(tex2, st);
    vec4 color3 = texture2D(tex3, st);

    gl_FragColor = color0 + color1 + color2 + color3;
}
