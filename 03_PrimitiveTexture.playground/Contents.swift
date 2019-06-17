
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

let textureCoodinateData: [Float] = [
    0, 1,
    1, 1,
    0, 0,
    1, 0
];
var textureCoodinateBuffer = device.makeBuffer(bytes: textureCoodinateData, length: textureCoodinateData.count * MemoryLayout<Float>.size)

let imagePath = Bundle.main.path(forResource: "img1", ofType: "png")!
var nsImage = NSImage(contentsOfFile: imagePath)!
var cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)!
let textureLoader = MTKTextureLoader(device: device)
var texture = try! textureLoader.newTexture(cgImage: cgImage, options: nil)

let shaderPath = Bundle.main.path(forResource: "Shader", ofType: "metal")!
let shaderText = try! NSString(contentsOfFile: shaderPath, encoding: String.Encoding.utf8.rawValue)
let library = try! device.makeLibrary(source: shaderText as String, options: nil)

let descriptor = MTLRenderPipelineDescriptor()
descriptor.vertexFunction = library.makeFunction(name: "vertexShader")
descriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
descriptor.colorAttachments[0].pixelFormat = texture.pixelFormat
var renderPipeline = try! device.makeRenderPipelineState(descriptor: descriptor)
let renderPassDescriptor = MTLRenderPassDescriptor()

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
        renderEncoder.setVertexBuffer(textureCoodinateBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentTexture(texture, index: 0)
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
mtkView.colorPixelFormat = texture.pixelFormat

PlaygroundSupport.PlaygroundPage.current.liveView = mtkView
