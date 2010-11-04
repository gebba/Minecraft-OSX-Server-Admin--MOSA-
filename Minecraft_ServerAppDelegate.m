//
//  Minecraft_ServerAppDelegate.m
//  Minecraft Server
//
//  Created by Johan Sjölin on 8/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Minecraft_ServerAppDelegate.h"
#import "ServerWrapper.h"

@implementation Minecraft_ServerAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {

	if (!flag) {
		[window makeKeyAndOrderFront:self];
	}
	
	return NO;
	
}

- (void)applicationWillTerminate:(NSNotification *)notification {

	NSTask *serverInstance = [ServerWrapper theServerTask];
	
	if ([serverInstance isRunning]) {
		[serverInstance terminate];
		[serverInstance waitUntilExit];
		NSLog(@"Server terminated upon application exit.");
	}
	
}

@end
