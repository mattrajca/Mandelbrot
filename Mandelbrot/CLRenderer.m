//
//  CLRenderer.m
//  Mandelbrot
//
//  Created by Matt on 10/11/15.
//  Copyright © 2015 Matt Rajca. All rights reserved.
//

#import "CLRenderer.h"

#import <OpenGL/gl.h>
#import <OpenCL/OpenCL.h>
#import "mandelbrot.cl.h"

@implementation CLRenderer

- (BOOL)isPrepared {
	return YES;
}

- (void)prepare { }

- (void)renderInContext:(id<RenderContext>)context {
	dispatch_queue_t queue = gcl_create_dispatch_queue(CL_DEVICE_TYPE_GPU, 0);

    [context allocateTextureWithHandler:^(GLuint texture, void (^token)(void)) {
		cl_image image = gcl_gl_create_image_from_texture(GL_TEXTURE_2D, 0, texture);

		dispatch_async(queue, ^{
			cl_ndrange range = { 2, {0,0}, { IMAGE_SIZE, IMAGE_SIZE }, {0,0} };
			mandelbrot_kernel(&range, image);
		});

		dispatch_barrier_sync(queue, ^{
			dispatch_async(dispatch_get_main_queue(), ^{
				token();
			});
		});

		gcl_release_image(image);
	}];
}

@end
