//
//  Player.h
//  Minecraft Server
//
//  Created by Johan Sjölin on 8/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Player : NSObject {

	NSString *name;
	NSNumber *rank;
	
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *rank;

- (id)initWithName:(NSString*)playerName;

@end
