//
//  Settings.m
//  Minecraft Server
//
//  Created by Johan Sjölin on 11/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"


@implementation Settings
@synthesize maxPlayers, javaMem, automaticBackups, backupFrequency;

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self loadSettingsFromFile];
	}
	return self;
}


- (void) saveSettingsToFile;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:SettingsSavedNotification object:self];
}

- (void) loadSettingsFromFile;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:SettingsLoadedNotification object:self];
}
@end
