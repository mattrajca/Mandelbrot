//
//  MetalTextureView.h
//  Mandelbrot
//
//  Created by Matt on 10/11/15.
//  Copyright © 2015 Matt Rajca. All rights reserved.
//

@import MetalKit;

@interface MetalTextureView : MTKView

@property (nonatomic) id <MTLTexture> texture;

@end
