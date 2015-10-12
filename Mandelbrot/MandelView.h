//
//  MandelView.h
//  Mandelbrot
//
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <OpenGL/OpenGL.h>

struct RGBA_ {
	float r;
	float g;
	float b;
	float a;
} __attribute__((packed));

typedef struct RGBA_ RGBA;

@interface MandelView : NSOpenGLView

- (GLuint)allocateTextureWithData:(void *)data;
- (void)clear;

@end
