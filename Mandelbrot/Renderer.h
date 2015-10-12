//
//  Renderer.h
//  Mandelbrot
//
//  Created by Matt on 10/11/15.
//  Copyright © 2015 Matt Rajca. All rights reserved.
//

@import Metal;

#import <OpenGL/OpenGL.h>
#import "RGBA.h"

@protocol RenderContext

- (GLuint)allocateTexture;

- (void)renderedTexture:(id <MTLTexture>)texture;
- (void)renderedBuffer:(RGBA *)data;

@end

@protocol Renderer

- (void)prepare;
- (void)renderInContext:(id <RenderContext>)context;

@end
