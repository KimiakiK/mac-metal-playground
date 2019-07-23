
import PlaygroundSupport
import Cocoa
import MetalKit

let device = MTLCreateSystemDefaultDevice()!
let mtkView = MTKView(frame: CGRect(x: 0, y: 0, width: 400, height: 400), device: device)
mtkView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

let allocator = MTKMeshBufferAllocator(device: device)
let mdlBoxMesh = MDLMesh(boxWithExtent: [0.8, 0.8, 0.8], segments: [10, 10, 10], inwardNormals: false, geometryType: .triangles, allocator: allocator)
let boxMesh = try MTKMesh(mesh: mdlBoxMesh, device: device)

let commandQueue = device.makeCommandQueue()!

let shaderPath = Bundle.main.path(forResource: "Shaders", ofType: "metal")!
let shaderText = try NSString(contentsOfFile: shaderPath, encoding: String.Encoding.utf8.rawValue)
let library = try device.makeLibrary(source: shaderText as String, options: nil)
let vertexFunction = library.makeFunction(name: "vertex_main")
let fragmentFunction = library.makeFunction(name: "fragment_main")

let pipelineDescriptor = MTLRenderPipelineDescriptor()
pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
pipelineDescriptor.vertexFunction = vertexFunction
pipelineDescriptor.fragmentFunction = fragmentFunction
pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(boxMesh.vertexDescriptor)

let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

struct Uniform
{
    var modelMatrix: float4x4
    var viewMatrix: float4x4
    var projectionMatrix: float4x4
}

var modelMatrix = makeMatrix(translate: [0.0, 0.0, 0.0], scale: [1.0, 1.0, 1.0], rotateDegree: [20.0, 45.0, 20.0])
print("Model Matrix:     ", modelMatrix.debugDescription)
var viewMatrix = makeMatrix(eye: [0.0, 0.0, -2.0], center: [0, 0, 0], up: [0, 1, 0])
print("View Matrix:      ", viewMatrix.debugDescription)
//var projectionMatrix = makeMatrix(orthogonalLeft: -1.0, right: 1.0, bottom: -1.0, top: 1.0, near: -10.0, far: 10.0)
var projectionMatrix = makeMatrix(perspectiveFovDegree: 40.0, aspect: 1.0, near: 0.001, far: 100.0)
print("Projection Matrix:", projectionMatrix.debugDescription)
print("Transform Matrix: ", (projectionMatrix * viewMatrix * modelMatrix).debugDescription)

var uniform = Uniform(modelMatrix: modelMatrix, viewMatrix: viewMatrix, projectionMatrix: projectionMatrix)

var radian: Float = 0.0

class MTKViewController: NSViewController, MTKViewDelegate
{
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // 処理なし
    }
    
    func draw(in view: MTKView) {
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderPassDescriptor = view.currentRenderPassDescriptor!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(boxMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        uniform.viewMatrix = makeMatrix(eye: [sin(radian)*2, 0.0, cos(radian)*2], center: [0.0, 0.0, 0.0], up: [0.0, 1.0, 0.0])
        radian += 0.01
        
        renderEncoder.setVertexBytes(&uniform, length: MemoryLayout<Uniform>.stride, index: 1)
        
        let submesh = boxMesh.submeshes.first!
        
        renderEncoder.drawIndexedPrimitives(type: .lineStrip, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: 0)
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}

let mtkViewController = MTKViewController()
mtkViewController.view = mtkView
mtkView.delegate = mtkViewController

PlaygroundSupport.PlaygroundPage.current.liveView = mtkView
