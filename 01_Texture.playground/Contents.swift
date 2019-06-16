
import PlaygroundSupport
import Cocoa
import MetalKit

let device = MTLCreateSystemDefaultDevice()!
var commandQueue = device.makeCommandQueue()!

let imagePath = Bundle.main.path(forResource: "img1", ofType: "png")!
var nsImage = NSImage(contentsOfFile: imagePath)!
var cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)!
let textureLoader = MTKTextureLoader(device: device)
var texture = try! textureLoader.newTexture(cgImage: cgImage, options: nil)

class ViewController: NSViewController, MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // ビューのリサイズ時に呼び出される
    }
    
    func draw(in view: MTKView) {
        // ビューの描画要求時に呼び出される
        let drawable = view.currentDrawable!
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(from: texture,
                         sourceSlice: 0,
                         sourceLevel: 0,
                         sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                         sourceSize: MTLSizeMake(texture.width, texture.height, texture.depth),
                         to: drawable.texture,
                         destinationSlice: 0,
                         destinationLevel: 0,
                         destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        
        blitEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}

var viewController = ViewController()
var mtkView = MTKView(frame: CGRect(x: 0, y: 0, width: texture.width/2, height: texture.height/2), device: device)
viewController.view = mtkView
mtkView.delegate = viewController

PlaygroundSupport.PlaygroundPage.current.liveView = mtkView
