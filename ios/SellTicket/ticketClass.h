//
//  ticketClass.h
//  SellTicket
//
//  Created by Eric Yu on 11/4/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ticketClass : NSObject

@property (nonatomic, strong) NSNumber *section;
@property (nonatomic, strong) NSNumber *row;
@property (nonatomic, strong) NSNumber *seat;

//See if you want to use NSNumbers for price instead
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *ticket_id; 
@property (nonatomic, strong) NSNumber *seller_id;

+(void)addTickets:(NSMutableDictionary *)tickets toGameID:(NSNumber *)game_id;
+(void)calculateHighest:(int *)highest andLowest:(int *)lowest inTickets:(NSMutableArray *)tickets;
@end
