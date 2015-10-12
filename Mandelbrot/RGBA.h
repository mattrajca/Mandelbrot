//
//  RGBA.h
//  Mandelbrot
//
//  Created by Matt on 10/11/15.
//  Copyright © 2015 Matt Rajca. All rights reserved.
//

#import <Foundation/Foundation.h>

struct RGBA_ {
	float r;
	float g;
	float b;
	float a;
} __attribute__((packed));

typedef struct RGBA_ RGBA;

extern void plot_point (RGBA *data, int x, int y, int size);
