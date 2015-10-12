//
//  LinearRenderer.m
//  Mandelbrot
//
//  Created by Matt on 10/11/15.
//  Copyright © 2015 Matt Rajca. All rights reserved.
//

#import "LinearRenderer.h"

#import "RGBA.h"

@implementation LinearRenderer

- (void)prepare { }

- (void)renderInContext:(id<RenderContext>)context {
	RGBA *data = malloc(sizeof(RGBA) * IMAGE_SIZE * IMAGE_SIZE);

	for (int y = 0; y < IMAGE_SIZE; y++) {
		for (int x = 0; x < IMAGE_SIZE; x++) {
			plot_point(data, x, y, IMAGE_SIZE);
		}
	}

	[context renderedBuffer:data];
	free(data);
}

@end
