//
//  MainViewController.h
//  Minecraft Server
//
//  Created by Johan Sjölin on 8/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServerWrapper.h"


@interface MainViewController : NSViewController <ServerWrapperDelegate, NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource> {
	
	// The actual server task
	ServerWrapper *theServer;
	
	// Backup timer
	NSTimer *backupTimer;
	
	// Settings panel outlets
	IBOutlet NSPanel *settingsPanel;
	IBOutlet NSTextField *settingsPanelMaxPlayers;
	IBOutlet NSComboBox *settingsPanelMemory;
	IBOutlet NSButton *settingsPanelBackupButton;
	IBOutlet NSTextField *settingsPanelBackupFrequency;
	
	// Folder paths
	NSString *settingsFolderPath;
	NSString *settingsBackupPath;
	NSString *settingsServerBinariesPath;
	NSString *settingsPath;
	NSString *serverBinary;
	
	// Settings
	NSInteger settingMaxPlayers;
	NSInteger settingJavaMem;
	BOOL settingAutomaticBackups;
	NSTimeInterval settingBackupFrequency;
	
	// Player stat variables
	NSInteger currentPlayerCount;
	NSMutableArray *currentPlayers;
	
	// Fields for input and output
	IBOutlet NSTextField *inputField;
	IBOutlet NSTextView *outputField;
	
	// Indicator for how many players are currently connected
	IBOutlet NSLevelIndicator *playerCountIndicator;
	
	// Table view for showing currently connected players
	IBOutlet NSTableView *playersTableView;
	
	// Start and stop buttons
	IBOutlet NSButton *startButton;
	IBOutlet NSButton *stopButton;
	
}

@property (nonatomic, retain) ServerWrapper *theServer;

// Main window actions
- (IBAction)startButtonClicked:(id)sender;
- (IBAction)stopButtonClicked:(id)sender;
- (IBAction)settingsButtonClicked:(id)sender;
- (void)updateLog:(NSString*)message;
- (void)reloadSettings;
- (void)backup:(NSTimer*)theTimer;

// Settings panel actions
- (IBAction)settingsSaveButtonClicked:(id)sender;
- (IBAction)settingsCloseButtonClicked:(id)sender;
- (void)saveSettings;

@end
