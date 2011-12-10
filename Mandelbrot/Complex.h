//
//  Complex.h
//  Mandelbrot
//
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#ifndef Mandelbrot_complex_h
#define Mandelbrot_complex_h

struct complex_t_ {
	float real;
	float imag;
};

typedef struct complex_t_ complex_t;

#define complex_add(a, b) (complex_t) { (a).real + (b).real, (a).imag + (b).imag }
#define complex_square(a) (complex_t) { (a).real * (a).real - (a).imag * (a).imag, (a).imag * (a).real + (a).real * (a).imag }

#endif
