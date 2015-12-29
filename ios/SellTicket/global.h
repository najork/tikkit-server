//
//  global.h
//  SellTicket
//
//  Created by Eric Yu on 11/11/15.
//  Copyright © 2015 myne. All rights reserved.
//

#ifndef global_h
#define global_h
@class KeychainItemWrapper;

//Ticket Dictionary
//Key: game_id
//Value: NSMutableArray of Tickets
extern NSMutableDictionary * ticketDictionary;

//Game Dictionary
//Key: school_id
//Value: NSMutableArray of Games
extern NSMutableDictionary * gameDictionary;

//School Dictionary
//Key: school_id
//Value: school_name
extern NSMutableDictionary * schoolDictionary;

extern NSMutableDictionary *gameIDToSchool;
#endif /* global_h */

// TODO: Get tokens properly
extern NSString * accessToken;
extern NSString * user_id;
extern NSString * serverAddress;

//Variables that represent get and post requests (1 and 0, but make it
//easier to read)
extern int GET;
extern int POST; 

