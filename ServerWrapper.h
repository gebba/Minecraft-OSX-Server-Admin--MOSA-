//
//  ServerWrapper.h
//  Minecraft Server
//
//  Created by Johan Sjölin on 8/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ServerWrapperDelegate;

@interface ServerWrapper : NSObject {

	id<ServerWrapperDelegate> delegate;
	
	NSInteger javaMem;
	
	//static NSTask *theServer; -- declared as static in implementation file
	
	NSPipe *outputPipe;
	NSFileHandle *outputDataSrc;
	NSPipe *errorPipe;
	NSFileHandle *errorDataSrc;
	NSPipe *inputPipe;
	NSFileHandle *inputDataSrc;
	
	//public
	BOOL isRunning;
	NSString *lastJoined;
	
}

@property (nonatomic, retain) id<ServerWrapperDelegate> delegate;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, retain) NSString *lastJoined;

- (id)initWithDelegate:(id<ServerWrapperDelegate>)newDelegate;

- (void)recievedData:(NSNotification*)notification;

- (void)startServer;
- (void)stopServer;
- (void)didReceiveServerTerminatedNotification;
- (void)debug:(NSString*)message;
- (void)setupServerTask;
- (void)reloadSettings;

// Server commands
- (void)doCommand:(NSString*)command;
- (void)say:(NSString*)message;
- (void)saveOn;
- (void)saveOff;
- (void)saveAll;
- (void)givePlayer:(NSString*)playerName item:(int)itemId count:(int)itemCount;
- (void)kickPlayer:(NSString*)playerName;

// Access to static NSTask server object
+ (NSTask*)theServerTask;

@end

// Delegate protocol
@protocol ServerWrapperDelegate

// Delegate method for returning the server log messages to owner
- (void)serverWrapperDidSendMessage:(NSString*)message;

// Called if a player types in the chat, returns name and message to delegate
- (void)serverWrapperChatMessageReceivedFrom:(NSString*)name message:(NSString*)chatMessage;

// Called when the server's player listing is displayed, returns an array of player names to delegate
- (void)serverWrapperPlayersListed:(NSArray*)players;

// Called when the player count is updated upon disconnect/connect, sending the current player count to delegate
- (void)serverWrapperPlayerCountUpdated:(NSInteger)playerCount;

// Called when a player joins, sending the name of that player to delegate
- (void)serverWrapperPlayerJoined:(NSString*)player;
- (void)serverWrapperPlayerDisconnected:(NSString*)player;

@end