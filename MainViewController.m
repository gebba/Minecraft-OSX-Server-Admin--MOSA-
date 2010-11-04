//
//  MainViewController.m
//  Minecraft Server
//
//  Created by Johan Sjölin on 8/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "Player.h"


@implementation MainViewController
@synthesize theServer;

- (void)awakeFromNib {
	
	// Setup folder paths
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	settingsFolderPath = [[documentsDirectory stringByAppendingPathComponent:@"MinecraftServerSettings"] retain];
	settingsBackupPath = [[settingsFolderPath stringByAppendingPathComponent:@"backups"] retain];
	settingsPath = [[settingsFolderPath stringByAppendingPathComponent:@"ServerSettings.plist"] retain];
	settingsServerBinariesPath = [[settingsFolderPath stringByAppendingPathComponent:@"server"] retain];
	serverBinary = [[settingsServerBinariesPath stringByAppendingPathComponent:@"minecraft_server.jar"] retain];
	
	// Set up notification listeners
	// Listener for settings save
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSettings) name:@"ServerSettingsSaved" object:self];
	// Listener for inputField end editing
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEditing:) name:NSControlTextDidEndEditingNotification object:inputField];
	
	// Load settings
	[self reloadSettings];
	
	theServer = [[ServerWrapper alloc] initWithDelegate:self];
	[playersTableView setDelegate:self];
	[playersTableView setDataSource:self];
	
	// Set the current players variable
	currentPlayerCount = 0;
	currentPlayers = [[NSMutableArray alloc] init];
	
	NSLog(@"Server interface loaded!");
	
}

- (IBAction)startButtonClicked:(id)sender {
	
	NSLog(@"Start button clicked!");
	[theServer startServer];
	
}

- (IBAction)stopButtonClicked:(id)sender {
	
	NSLog(@"Stop button clicked!");
	[theServer stopServer];
	
}

- (IBAction)settingsButtonClicked:(id)sender {
	
	[settingsPanel makeKeyAndOrderFront:sender];
	
}

#pragma mark World backup method

- (void)backup:(NSTimer*)theTimer {
	
	if ([theServer isRunning] && settingAutomaticBackups) {
		[theServer say:@"Server backup in progress..."];
		[theServer saveOff];
		[theServer saveAll];
		
		NSError *error;
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		settingsFolderPath = [documentsDirectory stringByAppendingPathComponent:@"MinecraftServerSettings"];
		settingsBackupPath = [settingsFolderPath stringByAppendingPathComponent:@"backups"];
		NSString *newBackupPath = [settingsBackupPath stringByAppendingPathComponent:[[[NSDate date] description] stringByReplacingOccurrencesOfString:@":" withString:@"."]];
		NSString *settingsWorldPath = [settingsServerBinariesPath stringByAppendingPathComponent:@"world"];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		if ([fileManager fileExistsAtPath:settingsWorldPath]) {
			
			if ([fileManager copyItemAtPath:settingsWorldPath toPath:newBackupPath error:&error]) {
				NSLog(@"File copy success");
			} else {
				NSLog(@"File copy fail");
			}
			
		} else {
			[self updateLog:@"No world files found... hmm?\n"];
		}

		
		[theServer saveOn];
		[theServer say:@"Server backup completed!"];
	}

}

#pragma mark Table view setup and methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {

	return [currentPlayers count];
	
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	Player *aPlayer = [currentPlayers objectAtIndex:row];
    return [aPlayer name];
}

#pragma mark ServerWrapper delegate methods

- (void)serverWrapperDidSendMessage:(NSString *)message {
	
	[self updateLog:message];
	
}

- (void)serverWrapperChatMessageReceivedFrom:(NSString*)name message:(NSString*)chatMessage {
	
	// TODO: add more player chat commands, and limit usage of some to ops/admins
	
	NSArray *messageSplit = [chatMessage componentsSeparatedByString:@" "];
	
	/*if ([[messageSplit objectAtIndex:0] isEqualToString:@"!give"]) {
		
		NSString *targetName = [messageSplit objectAtIndex:1];
		int count = [[messageSplit objectAtIndex:2] intValue];
		int item = [[messageSplit objectAtIndex:3] intValue];
		
		[theServer givePlayer:targetName item:item count:count];
		
	}*/
	
}

- (void)serverWrapperPlayersListed:(NSArray*)players {
	
	[theServer say:@"Online Players:"];
	
	for (NSString *player in players) {
	
		[theServer say:[NSString stringWithFormat:@"- %@", player]];
		
	}
	
}

- (void)serverWrapperPlayerCountUpdated:(NSInteger)playerCount {
	
	currentPlayerCount = playerCount;
	
	[playerCountIndicator setIntValue:playerCount];
	
	if (currentPlayerCount > settingMaxPlayers) {
		[theServer kickPlayer:[theServer lastJoined]];
	}
	
}

- (void)serverWrapperPlayerJoined:(NSString*)player {
	
	Player *newPlayer = [[Player alloc] initWithName:player];
	
	[currentPlayers addObject:newPlayer];
	[playersTableView reloadData];
	[newPlayer release];
	
}

- (void)serverWrapperPlayerDisconnected:(NSString*)player {

	Player *playerToBeRemoved;
	
	for (Player *aPlayer in currentPlayers) {
		if ([[aPlayer name] isEqualToString:player]) {
			playerToBeRemoved = aPlayer;
		}
	}
	[currentPlayers removeObject:playerToBeRemoved];
	[playersTableView reloadData];
	
}

- (void)updateLog:(NSString*)message {
	
	[outputField setEditable:YES];
	int textLength = [[outputField string] length];
	[outputField setSelectedRange:NSMakeRange(textLength, textLength)];
	[outputField insertText:message];
	[outputField setEditable:NO];
	
}

#pragma mark Settings panel actions
- (IBAction)settingsSaveButtonClicked:(id)sender {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ServerSettingsSaved" object:self];
	
}

- (IBAction)settingsCloseButtonClicked:(id)sender {
	
	[settingsPanel close];
	
}

-(void)saveSettings {
	
	[self updateLog:@"Saving...\n"];
	
	NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
	
	// Save max players setting to data object
	[data setObject:[NSNumber numberWithInt:[settingsPanelMaxPlayers intValue]] forKey:@"MaxPlayers"];
	
	// Save java memory setting to data object
	int javaMem = [[settingsPanelMemory objectValueOfSelectedItem] intValue];
	[data setObject:[NSNumber numberWithInt:javaMem] forKey:@"MaxJavaMemory"];
	
	// Save automatic backups true/false to data object
	if (settingsPanelBackupButton.state == NSOnState) {
		[data setValue:[NSNumber numberWithBool:YES] forKey:@"AutomaticBackups"];
	} else if (settingsPanelBackupButton.state == NSOffState) {
		[data setValue:[NSNumber numberWithBool:NO] forKey:@"AutomaticBackups"];
	}
	
	// Save backup frequency to data object
	[data setObject:[NSNumber numberWithInt:[settingsPanelBackupFrequency intValue]] forKey:@"BackupFrequency"];
	
	// Write data object to file
	[data writeToFile:settingsPath atomically:YES];
	[data release];
	
	[self reloadSettings];
	
}

- (void)reloadSettings {
	
	// Load settings, and create new settings file if it does not exist
	NSError *error;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath:serverBinary]) {
		
		NSAlert *alert = [NSAlert alertWithMessageText:@"Minecraft server jar missing!"
										 defaultButton:nil
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:[NSString stringWithFormat:
														@"Download the jar from www.minecraft.net and look for the folder named MinecraftServerSettings"
														@" in your documents folder. In there's another folder called server, place the jar there then run the application again."]];
		
		[alert runModal];
		
	}
	
	if (![fileManager fileExistsAtPath:settingsPath])
	{
		NSString *bundle = [[NSBundle mainBundle] pathForResource:@"DefaultServerSettings" ofType:@"plist"];
		
		[fileManager createDirectoryAtPath:settingsFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
		[fileManager createDirectoryAtPath:settingsBackupPath withIntermediateDirectories:NO attributes:nil error:&error];
		[fileManager createDirectoryAtPath:settingsServerBinariesPath withIntermediateDirectories:NO attributes:nil error:&error];
		[fileManager copyItemAtPath:bundle toPath:settingsPath error:&error];
		
	}
	
	NSMutableDictionary *serverSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
	
	settingMaxPlayers = [[serverSettings objectForKey:@"MaxPlayers"] intValue];
	[settingsPanelMaxPlayers setStringValue:[NSString stringWithFormat:@"%d", settingMaxPlayers]];
	
	settingJavaMem = [[serverSettings objectForKey:@"MaxJavaMemory"] intValue];
	[settingsPanelMemory selectItemWithObjectValue:[NSString stringWithFormat:@"%d", settingJavaMem]];
	
	settingAutomaticBackups = [[serverSettings objectForKey:@"AutomaticBackups"] boolValue];
	if (settingAutomaticBackups) {
		[settingsPanelBackupButton setState:NSOnState];
	} else if (!settingAutomaticBackups) {
		[settingsPanelBackupButton setState:NSOffState];
	}
	
	settingBackupFrequency = [[serverSettings objectForKey:@"BackupFrequency"] intValue] * 60;
	int freq = settingBackupFrequency;
	[settingsPanelBackupFrequency setStringValue:[NSString stringWithFormat:@"%d", freq / 60]];
	
	// Setup the player indicator
	[playerCountIndicator setMinValue:0];
	[playerCountIndicator setMaxValue:settingMaxPlayers];
	[playerCountIndicator setIntValue:currentPlayerCount];
	
	// Setup backup timer with newly loaded settings
	if (backupTimer) {
		NSLog(@"Timer already exists, removing");
		[backupTimer invalidate];
	}
	backupTimer = [NSTimer scheduledTimerWithTimeInterval:settingBackupFrequency target:self selector:@selector(backup:) userInfo:nil repeats:YES];
	
}

#pragma mark Input field delegate methods

- (void)textDidEndEditing:(NSNotification *)aNotification {

	if (![[inputField stringValue] isEqualToString:@""]) {
		[theServer doCommand:[inputField stringValue]];
	}
	
	[inputField setStringValue:@""];
	
}

- (void)dealloc {
	[super dealloc];
	[theServer release];
	[inputField release];
	[outputField release];
	[playerCountIndicator release];
	[playersTableView release];
	[startButton release];
	[stopButton release];
	
}

@end
