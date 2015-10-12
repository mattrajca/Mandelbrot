//
//  GCDRenderer.m
//  Mandelbrot
//
//  Created by Matt on 10/11/15.
//  Copyright © 2015 Matt Rajca. All rights reserved.
//

#import "GCDRenderer.h"

@implementation GCDRenderer

- (void)prepare { }

- (void)renderInContext:(id<RenderContext>)context {
	dispatch_queue_t queue = dispatch_queue_create("com.MattRajca.Mandelbrot.GCD", DISPATCH_QUEUE_CONCURRENT);

	RGBA *data = malloc(sizeof(RGBA) * IMAGE_SIZE * IMAGE_SIZE);

	dispatch_apply(IMAGE_SIZE, queue, ^(size_t y) {
		for (int x = 0; x < IMAGE_SIZE; x++) {
			plot_point(data, x, (int) y, IMAGE_SIZE);
		}
	});

	[context renderedBuffer:data];
	free(data);
}

@end
