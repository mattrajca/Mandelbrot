//
//  AppDelegate.m
//  Mandelbrot
//
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import "AppDelegate.h"

#import "CLRenderer.h"
#import "GCDRenderer.h"
#import "LinearRenderer.h"
#import "Mandelbrot-Swift.h"

#import "MetalTextureView.h"

#import <OpenCL/OpenCL.h>
#import <OpenGL/gl.h>
#import <sys/time.h>

@interface AppDelegate () <RenderContext>

@property (nonatomic, strong) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet NSPopUpButton *algorithmType;
@property (nonatomic, weak) IBOutlet NSView *containerView;
@property (nonatomic, weak) IBOutlet NSTextField *statusField;

@end


@implementation AppDelegate {
	NSView *_renderView;
	id <Renderer> _renderer;
	id <MTLDevice> _metalDevice;
	NSOpenGLView *_cachedGLView;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[self setUpRenderer:nil];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
	if (theItem.action == @selector(prepare:)) {
		return [_algorithmType indexOfSelectedItem] == 3;
	} else if (theItem.action == @selector(render:)) {
		if ([_algorithmType indexOfSelectedItem] == 3)
			return _renderer.isPrepared;
		else
			return YES;
	}

	return YES;
}

- (BOOL)hasGLView {
	return [_renderView isKindOfClass:[MandelView class]];
}

- (MandelView *)GLView {
	NSAssert([_renderView isKindOfClass:[MandelView class]], @"Unexpected view");

	if (![_renderView isKindOfClass:[MandelView class]])
		return nil;

	return (MandelView *)_renderView;
}

- (MetalTextureView *)metalView {
	NSAssert([_renderView isKindOfClass:[MetalTextureView class]], @"Unexpected view");

	if (![_renderView isKindOfClass:[MetalTextureView class]])
		return nil;

	return (MetalTextureView *)_renderView;
}

- (void)allocateTextureWithHandler:(void (^)(GLuint, void (^)()))handler {
	GLuint tid = [self.GLView allocateTextureWithData:NULL];
	handler(tid, ^{
		[self.GLView display];
	});
}

- (void)renderedTexture:(id <MTLTexture>)texture {
	self.metalView.texture = texture;
}

- (void)renderedBuffer:(RGBA *)data {
	[self.GLView allocateTextureWithData:(float *)data];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (IBAction)render:(id)sender {
	[_statusField setStringValue:@"Processing..."];
	[_statusField display];
	
	[self clear:nil];
	
	struct timeval start, end;
	gettimeofday(&start, NULL);
	
	[_renderer renderInContext:self];
	
	gettimeofday(&end, NULL);
	
	double fstart = (start.tv_sec * 1000000.0 + start.tv_usec) / 1000000.0;
	double fend = (end.tv_sec * 1000000.0 + end.tv_usec) / 1000000.0;
	
	[_statusField setStringValue:[NSString stringWithFormat:@"Took %.3f seconds", fend - fstart]];
}

- (IBAction)clear:(id)sender {
	if (self.hasGLView) {
		[self.GLView clear];
	} else if (self.metalView) {
		self.metalView.texture = nil;
	}
}

- (void)_setUpGLRenderer {
	[_renderView removeFromSuperview];

	NSOpenGLPixelFormatAttribute attributes[] = {
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADepthSize, 24,
		NSOpenGLPFAColorSize, 24,
		NSOpenGLPFAStencilSize, 16,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAAlphaSize, 8,
		NSOpenGLPFAAllowOfflineRenderers,
		0
	};

	NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];

	if (_cachedGLView) {
		_renderView = _cachedGLView;
	}
	else {
		_cachedGLView = [[MandelView alloc] initWithFrame:NSZeroRect pixelFormat:pixelFormat];
		_renderView = _cachedGLView;

		CGLContextObj context = _cachedGLView.openGLContext.CGLContextObj;
		gcl_gl_set_sharegroup(CGLGetShareGroup(context));
	}

	[self _addRenderView];
}

- (void)_setUpMetalRenderer {
	[_renderView removeFromSuperview];

	_metalDevice = MTLCreateSystemDefaultDevice();
	_renderView = [[MetalTextureView alloc] initWithFrame:NSZeroRect device:_metalDevice];

	[self _addRenderView];
}

- (void)_addRenderView {
	_renderView.translatesAutoresizingMaskIntoConstraints = NO;

	[_containerView addSubview:_renderView];

	[NSLayoutConstraint constraintWithItem:_renderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
	[NSLayoutConstraint constraintWithItem:_renderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
	[NSLayoutConstraint constraintWithItem:_renderView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0].active = YES;
	[NSLayoutConstraint constraintWithItem:_renderView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0].active = YES;
}

- (IBAction)setUpRenderer:(id)sender {
	switch ([_algorithmType indexOfSelectedItem]) {
		case 0:
			[self _setUpGLRenderer];
			_renderer = [[LinearRenderer alloc] init];
			break;
		case 1:
			[self _setUpGLRenderer];
			_renderer = [[GCDRenderer alloc] init];
			break;
		case 2:
			[self _setUpGLRenderer];
			_renderer = [[CLRenderer alloc] init];
			break;
		case 3:
			[self _setUpMetalRenderer];
			_renderer = [[MetalRenderer alloc] initWithDevice:_metalDevice];
			break;
		default:
			break;
	}

	[self.window.toolbar validateVisibleItems];
}

- (IBAction)prepare:(id)sender {
	[_renderer prepare];
	[self.window.toolbar validateVisibleItems];
}

@end
