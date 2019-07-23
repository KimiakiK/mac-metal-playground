
import MetalKit

func makeMatrix(translate: float3) -> float4x4
{
    var matrix = float4x4.init(1.0)
    matrix[3, 0] = translate.x
    matrix[3, 1] = translate.y
    matrix[3, 2] = translate.z
    return matrix
}

func makeMatrix(scale: float3) -> float4x4
{
    var matrix = float4x4.init(1.0)
    matrix[0, 0] = scale.x
    matrix[1, 1] = scale.y
    matrix[2, 2] = scale.z
    return matrix
}

func makeMatrix(rotateX rad: Float) -> float4x4
{
    var matrix = float4x4.init(1.0)
    matrix[1, 1] = cos(rad)
    matrix[1, 2] = sin(rad)
    matrix[2, 1] = -sin(rad)
    matrix[2, 2] = cos(rad)
    return matrix
}

func makeMatrix(rotateY rad: Float) -> float4x4
{
    var matrix = float4x4.init(1.0)
    matrix[0, 0] = cos(rad)
    matrix[0, 2] = -sin(rad)
    matrix[2, 0] = sin(rad)
    matrix[2, 2] = cos(rad)
    return matrix
}

func makeMatrix(rotateZ rad: Float) -> float4x4
{
    var matrix = float4x4.init(1.0)
    matrix[0, 0] = cos(rad)
    matrix[0, 1] = sin(rad)
    matrix[1, 0] = -sin(rad)
    matrix[1, 1] = cos(rad)
    return matrix
}

func makeMatrix(rotateRadian rad: float3) -> float4x4
{
    return makeMatrix(rotateX: rad.x) * makeMatrix(rotateY: rad.y) * makeMatrix(rotateZ: rad.z)
}

func makeMatrix(rotateDegree deg: float3) -> float4x4
{
    return makeMatrix(rotateRadian: deg * Float.pi / 180.0 )
}

public func makeMatrix(translate: float3, scale: float3, rotateRadian rad: float3) -> float4x4
{
    return makeMatrix(translate: translate) * makeMatrix(rotateRadian: rad) * makeMatrix(scale: scale)
}

public func makeMatrix(translate: float3, scale: float3, rotateDegree deg: float3) -> float4x4
{
    return makeMatrix(translate: translate) * makeMatrix(rotateDegree: deg) * makeMatrix(scale: scale)
}

public func makeMatrix(eye: float3, center: float3, up: float3) -> float4x4
{
    let cameraZ = simd_normalize(center - eye)
    let cameraX = simd_normalize(simd_cross(up, cameraZ))
    let cameraY = simd_cross(cameraZ, cameraX)
    
    var matrix = float4x4(columns: (simd_make_float4(cameraX), simd_make_float4(cameraY), simd_make_float4(cameraZ), [0.0, 0.0, 0.0, 1.0]))
    matrix[3, 0] = simd_dot(cameraX, -eye)
    matrix[3, 1] = simd_dot(cameraY, -eye)
    matrix[3, 2] = simd_dot(cameraZ, -eye)
    
    return matrix
}

public func makeMatrix(orthogonalLeft left:Float, right:Float, bottom:Float, top:Float, near:Float, far:Float) -> float4x4
{
    let translate = makeMatrix(translate: [-(right+left)/2.0, -(top+bottom)/2.0, -near])
    let scale = makeMatrix(scale: [2.0/(right-left), 2.0/(top-bottom), 1.0/(far-near)])
    
    return scale * translate
}

public func makeMatrix(perspectiveFovRadian fov:Float, aspect:Float, near:Float, far:Float) -> float4x4
{
    let scaleY = 1.0 / tan(fov / 2.0)
    let scaleX = scaleY / aspect
    let scaleZ = far / (far - near)
    
    var matrix = float4x4.init()
    matrix[0, 0] = scaleX
    matrix[1, 1] = scaleY
    matrix[2, 2] = scaleZ
    matrix[3, 2] = -near * scaleZ
    matrix[2, 3] = 1.0
    
    return matrix
}

public func makeMatrix(perspectiveFovDegree fov:Float, aspect:Float, near:Float, far:Float) -> float4x4
{
    return makeMatrix(perspectiveFovRadian: fov * Float.pi / 180.0, aspect: aspect, near: near, far: far)
}
