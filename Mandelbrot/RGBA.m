//
//  RGBA.m
//  Mandelbrot
//
//  Created by Matt on 10/11/15.
//  Copyright © 2015 Matt Rajca. All rights reserved.
//

#import "RGBA.h"

#import "Complex.h"

#define MAX_ITER 20

void plot_point (RGBA *data, int x, int y, int size) {
	int depth = -1;
	complex_t c = (complex_t) { x / (float) IMAGE_SIZE_3 - 2.0f, y / (float) IMAGE_SIZE_3 - 1.5f }, z = c;

	for (int i = 0; i < MAX_ITER; i++) {
		z = complex_add(complex_square(z), c);

		if (z.real * z.real + z.imag * z.imag > 4) {
			depth = i;
			break;
		}
	}

	if (depth < 0) {
		data[y * size + x] = (RGBA) { 0.0f, 0.0f, 0.0f, 1.0f };
	}
	else {
		data[y * size + x] = (RGBA) { 0.0f, 1.0f / (20-depth) * 4, 1.0f / (20-depth) * 8, 1.0f };
	}
}
