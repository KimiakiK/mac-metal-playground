
#include <metal_stdlib>
using namespace metal;

struct ColorInOut
{
    float4 position [[ position ]];
};

vertex ColorInOut vertexShader(device float4* positions [[ buffer(0) ]],
                               uint vid [[ vertex_id ]])
{
    ColorInOut out;
    // 操作なし
    out.position = positions[vid];
    return out;
}

fragment float4 fragmentShader(ColorInOut in [[ stage_in ]])
{
    // 操作なし
    return float4(1.0, 1.0, 0.0, 1.0);
}


fragment float4 fragmentShader2(ColorInOut in [[ stage_in ]])
{
    // 操作なし
    return float4(0.0, 1.0, 1.0, 1.0);
}
