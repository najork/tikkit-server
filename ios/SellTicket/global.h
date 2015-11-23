//
//  global.h
//  SellTicket
//
//  Created by Eric Yu on 11/11/15.
//  Copyright © 2015 myne. All rights reserved.
//

#ifndef global_h
#define global_h

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
#endif /* global_h */
