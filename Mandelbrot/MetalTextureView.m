//
//  MetalTextureView.m
//  Mandelbrot
//
//  Created by Matt on 10/11/15.
//  Copyright © 2015 Matt Rajca. All rights reserved.
//

#import "MetalTextureView.h"

float spriteVertexData[16] = {
	-1.0, -1.0,  0.0, 1.0,
	1.0, -1.0,  1.0, 1.0,
	-1.0,  1.0,  0.0, 0.0,
	1.0,  1.0,  1.0, 0.0,
};

@implementation MetalTextureView {
	id <MTLBuffer> _vertexBuffer;
	id <MTLRenderPipelineState> _pipelineState;
	id <MTLCommandQueue> _commandQueue;
	MTLRenderPassDescriptor *_renderPassDescriptor;
}

- (instancetype)initWithFrame:(CGRect)frameRect device:(id<MTLDevice>)device {
	if (!(self = [super initWithFrame:frameRect device:device]))
		return nil;

	self.framebufferOnly = YES;
	self.paused = YES;
	self.enableSetNeedsDisplay = YES;

	_commandQueue = [self.device newCommandQueue];
	_vertexBuffer = [self.device newBufferWithBytes:spriteVertexData length:sizeof(spriteVertexData) options:MTLResourceOptionCPUCacheModeDefault];
	_vertexBuffer.label = @"Vertices";

	dispatch_async(dispatch_get_main_queue(), ^{
		id <MTLLibrary> defaultLibrary = [self.device newDefaultLibrary];

		MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
		pipelineStateDescriptor.sampleCount = 1;
		pipelineStateDescriptor.vertexFunction = [defaultLibrary newFunctionWithName:@"vertexPassthrough"];
		pipelineStateDescriptor.fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentSampler"];
		pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
		pipelineStateDescriptor.depthAttachmentPixelFormat = MTLPixelFormatInvalid;

		NSError *error;
		_pipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];

		if (!_pipelineState)
			NSLog(@"Failed to created pipeline state with error %@", error);
	});
	
	return self;
}

- (void)setTexture:(id<MTLTexture>)texture {
	if (texture == _texture)
		return;

	_texture = texture;
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
	id <MTLCommandBuffer> commandBuffer = _commandQueue.commandBuffer;
	commandBuffer.label = @"Drawing command buffer";

	id <CAMetalDrawable> drawable = self.currentDrawable;

	if (!_renderPassDescriptor)
		_renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];

	_renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
	_renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
	_renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;

	id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_renderPassDescriptor];
	renderEncoder.label = @"Drawing encoder";

	if (_texture) {
		[renderEncoder pushDebugGroup:@"Drawing sprite"];
		[renderEncoder setRenderPipelineState:_pipelineState];
		[renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
		[renderEncoder setFragmentTexture:_texture atIndex:0];

		[renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4 instanceCount:1];
		[renderEncoder popDebugGroup];
	}

	[renderEncoder endEncoding];

	[commandBuffer presentDrawable:drawable];
	[commandBuffer commit];
}

@end
