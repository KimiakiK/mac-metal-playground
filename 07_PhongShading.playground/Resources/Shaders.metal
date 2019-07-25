#include <metal_stdlib>
using namespace metal;

struct VertexIn
{
    float4 position [[attribute(0)]];
    float3 normal   [[attribute(1)]];
};

struct VertexOut
{
    float4 position [[position]];
    float3 normal;
};

struct Uniform
{
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[stage_in]],
                          constant Uniform &uniform [[buffer(1)]])
{
    VertexOut out;
    out.position = uniform.projectionMatrix * uniform.viewMatrix * uniform.modelMatrix * vertex_in.position;
    out.normal = vertex_in.normal;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]])
{
    float3 source = normalize(float3(-1.0, -1.0, -1.0));
    float light = dot(in.normal, source);
    return float4(float3(light), 1.0);
}
