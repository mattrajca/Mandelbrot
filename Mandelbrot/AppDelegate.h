//
//  AppDelegate.h
//  Mandelbrot
//
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import "MandelView.h"

@interface AppDelegate : NSObject < NSApplicationDelegate >

@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (nonatomic, assign) IBOutlet NSPopUpButton *algorithmType;
@property (nonatomic, assign) IBOutlet MandelView *mandelView;
@property (nonatomic, assign) IBOutlet NSTextField *statusField;

- (IBAction)render:(id)sender;
- (IBAction)clear:(id)sender;

- (void)computeLinearly;
- (void)computeUsingGCD;
- (void)computeUsingCL;

@end
