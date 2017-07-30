//
//  MetalRenderer.swift
//  Mandelbrot
//
//  Created by Matt on 10/11/15.
//  Copyright © 2015 Matt Rajca. All rights reserved.
//

import Foundation
import Metal

class MetalRenderer: NSObject, Renderer {
    func render(in context: RenderContext!) {
        guard let computePipelineState = computePipelineState else {
            fatalError()
        }
        
        let outTexture = device.makeTexture(descriptor: outputTextureDescriptor)
        
        let buffer = commandQueue.makeCommandBuffer()
        let encoder = buffer.makeComputeCommandEncoder()
        encoder.setComputePipelineState(computePipelineState)
        encoder.setTexture(outTexture, at: 0)
        
        let threadGroupCount = MTLSizeMake(32, 32, 1)
        let threadGroups = MTLSizeMake(outTexture.width / threadGroupCount.width, outTexture.height / threadGroupCount.height, 1)
        
        encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        encoder.endEncoding()
        
        buffer.commit()
        buffer.waitUntilCompleted()
        
        context.renderedTexture(outTexture)
    }
    
	private let device: MTLDevice

	private var commandQueue: MTLCommandQueue!
	private var outputTextureDescriptor: MTLTextureDescriptor!
	private var computePipelineState: MTLComputePipelineState?

	@objc var isPrepared = false

	init(device: MTLDevice) {
		self.device = device

		super.init()
	}

	func prepare() {
		guard let library = device.newDefaultLibrary() else {
			fatalError("Could not get the default library")
		}

        guard let mandelbrotFunction = library.makeFunction(name: "mandelbrot") else {
			fatalError("Could not get the mandelbrot function")
		}

        device.makeComputePipelineState(function: mandelbrotFunction) { state, error in
			if let state = state {
				self.computePipelineState = state
			} else if let error = error {
				print("Could not create the pipeline state: \(error)")
			}
		}

        commandQueue = device.makeCommandQueue()

        outputTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 4096, height: 4096, mipmapped: false)
        outputTextureDescriptor.resourceOptions = [.storageModePrivate]
        outputTextureDescriptor.storageMode = MTLStorageMode.private
        outputTextureDescriptor.usage = [.shaderWrite, .shaderRead];

		isPrepared = true
	}

}
