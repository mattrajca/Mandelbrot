//
//  MandelView.h
//  Mandelbrot
//
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

struct RGB_ {
	float r;
	float g;
	float b;
} __attribute__((packed));

typedef struct RGB_ RGB;

@interface MandelView : NSOpenGLView

- (GLuint)allocateTextureWithData:(const GLvoid *)data;
- (void)clear;

@end
