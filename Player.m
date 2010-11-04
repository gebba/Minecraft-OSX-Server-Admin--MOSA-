//
//  Player.m
//  Minecraft Server
//
//  Created by Johan Sjölin on 8/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Player.h"


@implementation Player
@synthesize name, rank;

- (id)initWithName:(NSString*)playerName {

	self = [super init];
	
	name = playerName;
	
	return self;
	
}

@end
