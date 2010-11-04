//
//  Settings.h
//  Minecraft Server
//
//  Created by Johan Sjölin on 11/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *SettingsSavedNotification = @"SettingsSaved";
static NSString *SettingsLoadedNotification = @"SettingsLoaded";

@interface Settings : NSObject {
	NSInteger maxPlayers;
	NSInteger javaMem;
	BOOL automaticBackups;
	NSTimeInterval backupFrequency;
}

@property (nonatomic) NSInteger maxPlayers;
@property (nonatomic) NSInteger javaMem;
@property (nonatomic) BOOL automaticBackups;
@property (nonatomic) NSTimeInterval backupFrequency;

- (void) saveSettingsToFile;
- (void) loadSettingsFromFile;

@end
