
#include <metal_stdlib>
using namespace metal;

struct ColorInOut
{
    float4 position [[ position ]];
    float2 textureCoordinate;
};

vertex ColorInOut vertexShader(device float4* positions [[ buffer(0) ]],
                               device float2* textureCoordinate [[ buffer(1) ]],
                               uint vid [[ vertex_id ]])
{
    ColorInOut out;
    // 操作なし
    out.position = positions[vid];
    out.textureCoordinate = textureCoordinate[vid];
    return out;
}

fragment float4 fragmentShader(ColorInOut in [[ stage_in ]],
                               texture2d<float> texture [[ texture(0) ]])
{
    constexpr sampler colorSampler;
    float4 color = texture.sample(colorSampler, in.textureCoordinate);
    return color;
}
