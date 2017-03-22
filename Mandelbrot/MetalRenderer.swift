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

		guard let mandelbrotFunction = library.newFunctionWithName("mandelbrot") else {
			fatalError("Could not get the mandelbrot function")
		}

		device.newComputePipelineStateWithFunction(mandelbrotFunction) { state, error in
			if let state = state {
				self.computePipelineState = state
			} else if let error = error {
				print("Could not create the pipeline state: \(error)")
			}
		}

		commandQueue = device.newCommandQueue()

		outputTextureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.RGBA8Unorm, width: 4096, height: 4096, mipmapped: false)
		outputTextureDescriptor.resourceOptions = [.StorageModePrivate]
		outputTextureDescriptor.storageMode = MTLStorageMode.Private
		outputTextureDescriptor.usage = [.ShaderWrite, .ShaderRead]

		isPrepared = true
	}

	func renderInContext(context: RenderContext) {
		guard let computePipelineState = computePipelineState else {
			fatalError()
		}

		let outTexture = device.newTextureWithDescriptor(outputTextureDescriptor)

		let buffer = commandQueue.commandBuffer()
		let encoder = buffer.computeCommandEncoder()
		encoder.setComputePipelineState(computePipelineState)
		encoder.setTexture(outTexture, atIndex: 0)

		// FIXME: Changed from 32 to 16 to prevent Run time error: threadGroupCount must be <= 512	
		let threadGroupCount = MTLSizeMake(32, 16, 1)
		let threadGroups = MTLSizeMake(outTexture.width / threadGroupCount.width, outTexture.height / threadGroupCount.height, 1)

		encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
		encoder.endEncoding()

		buffer.commit()
		buffer.waitUntilCompleted()

		context.renderedTexture(outTexture)
	}
}
