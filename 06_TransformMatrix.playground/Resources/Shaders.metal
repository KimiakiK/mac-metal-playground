#include <metal_stdlib>
using namespace metal;

struct Vertex
{
    float4 position [[attribute(0)]];
};

struct Uniform
{
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

vertex float4 vertex_main(const Vertex vertex_in [[stage_in]],
                          constant Uniform &uniform [[buffer(1)]])
{
    return uniform.projectionMatrix * uniform.viewMatrix * uniform.modelMatrix * vertex_in.position;
}

fragment float4 fragment_main()
{
    return float4(1.0, 0.0, 0.0, 1.0);
}
