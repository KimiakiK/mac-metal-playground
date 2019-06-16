
import PlaygroundSupport
import Cocoa
import MetalKit

let device = MTLCreateSystemDefaultDevice()!
var commandQueue = device.makeCommandQueue()!

let vertexData: [Float] = [
    -1.0, -1.0, 0.0, 1.0,
     1.0, -1.0, 0.0, 1.0,
    -1.0,  1.0, 0.0, 1.0,
     1.0,  1.0, 0.0, 1.0
]
var vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Float>.size)

let vertexData2: [Float] = [
    -0.5, -0.5, 0.0, 1.0,
     0.5, -0.5, 0.0, 1.0,
    -0.5,  0.5, 0.0, 1.0,
     0.5,  0.5, 0.0, 1.0
]
var vertexBuffer2 = device.makeBuffer(bytes: vertexData2, length: vertexData2.count * MemoryLayout<Float>.size)

// シェーダファイルのパスを取得
let shaderPath = Bundle.main.path(forResource: "Shader", ofType: "metal")!
// シェーダファイルをテキストとして取得
let shaderText = try! NSString(contentsOfFile: shaderPath, encoding: String.Encoding.utf8.rawValue)
// テキストからシェーダをコンパイル
let library = try! device.makeLibrary(source: shaderText as String, options: nil)

let descriptor = MTLRenderPipelineDescriptor()
descriptor.vertexFunction = library.makeFunction(name: "vertexShader")
descriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
var renderPipeline = try! device.makeRenderPipelineState(descriptor: descriptor)
let renderPassDescriptor = MTLRenderPassDescriptor()

let descriptor2 = MTLRenderPipelineDescriptor()
descriptor2.vertexFunction = library.makeFunction(name: "vertexShader")
descriptor2.fragmentFunction = library.makeFunction(name: "fragmentShader2")
descriptor2.colorAttachments[0].pixelFormat = .bgra8Unorm
var renderPipeline2 = try! device.makeRenderPipelineState(descriptor: descriptor2)

class ViewController: NSViewController, MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // ビューのリサイズ時に呼び出される
    }
    
    func draw(in view: MTKView) {
        // ビューの描画要求時に呼び出される
        let drawable = view.currentDrawable!
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(renderPipeline)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.setRenderPipelineState(renderPipeline2)
        renderEncoder.setVertexBuffer(vertexBuffer2, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}

var viewController = ViewController()
var mtkView = MTKView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), device: device)
viewController.view = mtkView
mtkView.delegate = viewController

PlaygroundSupport.PlaygroundPage.current.liveView = mtkView
