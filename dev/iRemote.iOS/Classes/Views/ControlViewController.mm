/**
 * Copyright (c) 2013 Egor Pushkin. All rights reserved.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ControlViewController.h"
#import "../Controls/ControlArea.h"
#import "../Main/iRemoteAppDelegate.h"
#import "../Controls/ScreenshotProvider.h"
#import "../Doc/HelpController.h"

@interface ControlViewController (PrivateMethods)

- (void)updateControls:(NSTimeInterval)duration;

@end

#include "Connector/Server.h"
#include "Versions/Features.h"
#include "KeyCodes/VirtualCodes.Win32.h"

@implementation ControlViewController

@synthesize controlArea;

- (IBAction)onQuit {
    // Close current connection.
    RemotePC::Holder::Instance().Stop();
    // Notify UI.
    [[iRemoteAppDelegate delegate] onQiut];         
}

- (IBAction)onHelp {
    // Display help content.
	[HelpController showOnTopOf:self];
}

#pragma mark Mouse and zoom controls

- (IBAction)onLeftDown {
    RemotePC::Holder::Instance().OnLeftDown();    
}

- (IBAction)onLeftUp {
    RemotePC::Holder::Instance().OnLeftUp();    
}

- (IBAction)onMiddleDown {
    RemotePC::Holder::Instance().OnMiddleDown();        
}

- (IBAction)onMiddleUp {
    RemotePC::Holder::Instance().OnMiddleUp();    
}

- (IBAction)onRightDown {
    RemotePC::Holder::Instance().OnRightDown();    
}

- (IBAction)onRightUp {
    RemotePC::Holder::Instance().OnRightUp();    
}

#pragma mark Text field delegate

- (BOOL)isKeyboardPresented {
    return [hiddenEdit isFirstResponder];
}

- (IBAction)toggleKeybopard {
    if ( [self isKeyboardPresented] )
        [hiddenEdit resignFirstResponder];
    else
        [hiddenEdit becomeFirstResponder];
    [self updateControls:0.5f];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {    
    // Test on backspace button.
    if ( [string length] == 0 ) {
        // Backspace button has been pressed. Notify host on event.
        RemotePC::Holder::Instance().OnVirtualKey(VK_BACK, true);
        RemotePC::Holder::Instance().OnVirtualKey(VK_BACK, false);
    } else {
        // Acquire key code.
        unichar character = [string characterAtIndex:0]; 
        // Notify host on event.
        RemotePC::Holder::Instance().OnUnicodeKey( character );        
    }    
    // Clear hidden field.
    hiddenEdit.text = @" ";       
    return NO;    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Notify host on 'Enter' key pressed.
    RemotePC::Holder::Instance().OnVirtualKey(VK_RETURN, true);
    RemotePC::Holder::Instance().OnVirtualKey(VK_RETURN, false);    
    // Clear hidden field.
    hiddenEdit.text = @" ";       
    return NO;       
}

#pragma mark View transformation

- (CGSize)controlAreaSize:(UIInterfaceOrientation)interfaceOrientation {
    CGSize area = CGSizeZero;
    if ( [self isKeyboardPresented] ) {
        if ( UIInterfaceOrientationIsPortrait(interfaceOrientation) ) 
            area = CGSizeMake(320.0f, 200.0f);
        else
            area = CGSizeMake(480.0f, 138.0f);    
    } else {        
        if ( UIInterfaceOrientationIsPortrait(interfaceOrientation) ) 
            area = CGSizeMake(320.0f, 367.0f);
        else
            area = CGSizeMake(480.0f, 300.0f);
    }
    return area;
}

- (void)updateControlsToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // Update control area.
    CGSize area = [self controlAreaSize:toInterfaceOrientation];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration / 2.0f];
    controlArea.frame = CGRectMake( 
        controlArea.frame.origin.x,
        controlArea.frame.origin.y, 
        area.width,
        area.height);
    // Update mouse controls within the same animation block.
    CGFloat controlAlpha = 1.0;
    if ( [self isKeyboardPresented] ) 
        controlAlpha = 0.0;
    mouseControls.alpha = controlAlpha;
    [UIView commitAnimations];
}

- (void)updateControls:(NSTimeInterval)duration {
    [self updateControlsToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:duration];
}

#pragma mark View controller section

- (void)viewDidLoad {
	[super viewDidLoad];
	// Enable zoom only for main control area. 
	controlArea.zoomEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Add single space to edit field to distinguish backspace button.
    hiddenEdit.text = @" ";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[ScreenshotProvider instance] setScreenshotHost:controlArea];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[ScreenshotProvider instance] setScreenshotHost:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Unsubscribe from screenshots while rotating.
    [[ScreenshotProvider instance] setScreenshotHost:nil];    
    // Adjust controls to fit new orientation.    
    [self updateControlsToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation]; 
    
    // Subscribe on screenshots when rotation is complete.
    [[ScreenshotProvider instance] setScreenshotHost:controlArea];
}

#pragma mark Tabbar controller section

- (void)connected {
    // Check whether RemotePC supports zooming.
    int major = 0, minor = 0;
    controlArea.zoomSupported = 
		( mc::Error::IsSucceeded(RemotePC::Holder::Instance().GetRemotePCVersion(major, minor)) ) &&
		( RemotePC::Features::RemotePCZooming(major, minor) );	
}
	
#pragma mark Life cycle tools

- (void)dealloc {
    [controlArea release];
    [super dealloc];
}

@end