
import PlaygroundSupport
import Cocoa
import MetalKit
import simd


let device = MTLCreateSystemDefaultDevice()!
var mtkView = MTKView(frame: CGRect(x: 0, y: 0, width: 400, height: 400), device: device)
mtkView.colorPixelFormat = .bgra8Unorm

let triangleVertices: [Float] =
[
        // 2D positions,              RGBA colors
         1.0, -1.0, 0.0, 1.0,         1, 0, 0, 1,
        -1.0, -1.0, 0.0, 1.0,         0, 1, 0, 1,
         0.0,  1.0, 0.0, 1.0,         0, 0, 1, 1
]
var triangleVerticesBuffer = device.makeBuffer(bytes: triangleVertices, length: triangleVertices.count * MemoryLayout<Float>.size)

let shaderPath = Bundle.main.path(forResource: "Shaders", ofType: "metal")!
let shaderText = try! NSString(contentsOfFile: shaderPath, encoding: String.Encoding.utf8.rawValue)
let library = try! device.makeLibrary(source: shaderText as String, options: nil)

let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
pipelineStateDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
pipelineStateDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat

var pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

var commandQueue = device.makeCommandQueue()!

class MTKViewController: NSViewController, MTKViewDelegate
{
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // 処理なし
    }
    
    func draw(in view: MTKView) {
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderPassDescriptor = view.currentRenderPassDescriptor!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        renderEncoder.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: 800.0, height: 800.0, znear: 0.0, zfar: 1.0))
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(triangleVerticesBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 3)
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}

var mtkViewController = MTKViewController()
mtkViewController.view = mtkView
mtkView.delegate = mtkViewController

PlaygroundSupport.PlaygroundPage.current.liveView = mtkView

