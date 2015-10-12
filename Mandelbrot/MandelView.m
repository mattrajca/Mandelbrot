//
//  MandelView.m
//  Mandelbrot
//
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import "MandelView.h"

#import <OpenCL/OpenCL.h>
#import <OpenGL/gl.h>

@implementation MandelView {
	BOOL _hasTexture;
	GLuint _texture;
}

- (instancetype)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format {
	if (!(self = [super initWithFrame:frameRect pixelFormat:format]))
		return nil;

	CGLContextObj context = [[self openGLContext] CGLContextObj];
	gcl_gl_set_sharegroup(CGLGetShareGroup(context));

	return self;
}

- (GLuint)allocateTextureWithData:(void *)data {
	glGenTextures(1, &_texture);
	
	glBindTexture(GL_TEXTURE_2D, _texture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, IMAGE_SIZE, IMAGE_SIZE, 0, GL_RGBA, GL_FLOAT, data);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	_hasTexture = YES;
	
	if (data)
		[self display];
	
	return _texture;
}

- (void)_deleteTexture {
	if (!_hasTexture)
		return;

	glDeleteTextures(1, &_texture);

	_texture = 0;
	_hasTexture = NO;
}

- (void)clear {
	[self _deleteTexture];
	[self display];
}

- (void)reshape {
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	glEnable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	glShadeModel(GL_SMOOTH);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0.0f, 512.0f, 512.0f, 0.0f, 0.0f, 1.0f);
}

- (void)drawRect:(NSRect)dirtyRect {
	glClear(GL_COLOR_BUFFER_BIT);
	
	if (!_hasTexture) {
		glFlush();
		return;
	}
	
	glBindTexture(GL_TEXTURE_2D, _texture);

	glBegin(GL_QUADS);
	{
		glTexCoord2f(0.0f, 0.0f); glVertex3f(0.0f,   0.0f,   0.0f);
		glTexCoord2f(1.0f, 0.0f); glVertex3f(512.0f, 0.0f,   0.0f);
		glTexCoord2f(1.0f, 1.0f); glVertex3f(512.0f, 512.0f, 0.0f);
		glTexCoord2f(0.0f, 1.0f); glVertex3f(0.0f,   512.0f, 0.0f);
	}
	glEnd();

	glFlush();
}

- (void)dealloc {
	[self _deleteTexture];
}

@end
