//
//  AppDelegate.m
//  Mandelbrot
//
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import "AppDelegate.h"

#import <OpenGL/gl.h>
#import <OpenCL/OpenCL.h>
#import <sys/time.h>

#import "Complex.h"
#import "mandelbrot.cl.h"

@interface AppDelegate ()

@property (nonatomic, strong) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet NSPopUpButton *algorithmType;
@property (nonatomic, weak) IBOutlet MandelView *mandelView;
@property (nonatomic, weak) IBOutlet NSTextField *statusField;

@end

@implementation AppDelegate

#define MAX_ITER 20

- (void)awakeFromNib {
	CGLContextObj context = [[_mandelView openGLContext] CGLContextObj];
	gcl_gl_set_sharegroup(CGLGetShareGroup(context));
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
	
	if ([_algorithmType indexOfSelectedItem] == 0) {
		[self computeLinearly];
	}
	else if ([_algorithmType indexOfSelectedItem] == 1) {
		[self computeUsingGCD];
	}
	else if ([_algorithmType indexOfSelectedItem] == 2) {
		[self computeUsingCL];
	}
	
	gettimeofday(&end, NULL);
	
	double fstart = (start.tv_sec * 1000000.0 + start.tv_usec) / 1000000.0;
	double fend = (end.tv_sec * 1000000.0 + end.tv_usec) / 1000000.0;
	
	[_statusField setStringValue:[NSString stringWithFormat:@"Took %.3f seconds", fend - fstart]];
}

- (IBAction)clear:(id)sender {
	[_mandelView clear];
}

- (void)computeLinearly {
	RGB *data = malloc(sizeof(RGB) * IMAGE_SIZE * IMAGE_SIZE);
	
	for (int y = 0; y < IMAGE_SIZE; y++) {
		for (int x = 0; x < IMAGE_SIZE; x++) {
			plot_point(data, x, y, IMAGE_SIZE);
		}
	}
	
	[_mandelView allocateTextureWithData:data];
	free(data);
}

- (void)computeUsingGCD {
	dispatch_queue_t queue = dispatch_queue_create("com.MattRajca.Mandelbrot.GCD", DISPATCH_QUEUE_CONCURRENT);
	
	RGB *data = malloc(sizeof(RGB) * IMAGE_SIZE * IMAGE_SIZE);
	
	dispatch_apply(IMAGE_SIZE, queue, ^(size_t y) {
		for (int x = 0; x < IMAGE_SIZE; x++) {
			plot_point(data, x, (int) y, IMAGE_SIZE);
		}
	});
	
	[_mandelView allocateTextureWithData:data];
	free(data);
}

- (void)computeUsingCL {
	dispatch_queue_t queue = gcl_create_dispatch_queue(CL_DEVICE_TYPE_GPU, 0);
	
	GLuint texture = [_mandelView allocateTextureWithData:NULL];
	cl_image image = gcl_gl_create_image_from_texture(GL_TEXTURE_2D, 0, texture);
	
	dispatch_async(queue, ^{
		cl_ndrange range = { 2, {0,0}, { IMAGE_SIZE, IMAGE_SIZE }, {0,0} };
		mandelbrot_kernel(&range, image);
	});
	
	dispatch_barrier_sync(queue, ^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[_mandelView display];
		});
	});
	
	gcl_release_image(image);
}

static void plot_point (RGB *data, int x, int y, int size) {
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
		data[y * size + x] = (RGB) { 0.0f, 0.0f, 0.0f };
	}
	else {
		data[y * size + x] = (RGB) { 0.0f, 1.0f / (20-depth) * 4, 1.0f / (20-depth) * 8 };
	}
}

@end
