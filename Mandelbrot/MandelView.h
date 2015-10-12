//
//  MandelView.h
//  Mandelbrot
//
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <OpenGL/OpenGL.h>

@interface MandelView : NSOpenGLView

- (GLuint)allocateTextureWithData:(void *)data;
- (void)clear;

@end
