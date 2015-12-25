//
//  ticketClass.m
//  SellTicket
//
//  Created by Eric Yu on 11/4/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import "ticketClass.h"
#import "Global.h"

@implementation ticketClass

-(id) init {
    return self; 
}

+(void)addTickets:(NSMutableDictionary *)tickets toGameID:(NSNumber *)game_id {
    for(id ticket in tickets) {
        ticketClass *newTicket = [[ticketClass alloc] init];
        newTicket.section = [ticket objectForKey:@"section"];
        newTicket.row = [ticket objectForKey:@"row"];
        newTicket.price = [ticket objectForKey:@"price"];
        newTicket.seat = [ticket objectForKey:@"seat"];
        newTicket.ticket_id = [ticket objectForKey:@"ticket_id"];
        newTicket.seller_id = [ticket objectForKey:@"seller_id"];
        NSNumber *game_id = [ticket objectForKey:@"game_id"];
        
        
        if([ticketDictionary objectForKey:game_id]) {
            NSMutableArray *array = [ticketDictionary objectForKey:game_id];
            
            //If ticket already exists, we continue. If not, we add to the
            //array
            BOOL exists = NO;
            for(ticketClass *ticket in array) {
                if([ticket.ticket_id intValue] == [newTicket.ticket_id intValue]) {
                    exists = YES;
                    break;
                }
            }
            if(exists) {
                continue;
            }
            
            [array addObject:newTicket];
        } else {
            NSMutableArray *newArray = [[NSMutableArray alloc]init];
            [newArray addObject:newTicket];
            [ticketDictionary setObject:newArray forKey:game_id];
        }
    }
}

+(void)calculateHighest:(int *)highest andLowest:(int *)lowest inTickets:(NSMutableArray *)tickets {
    for(ticketClass *ticket in tickets) {
        if((NSNumber *)[NSNull null] != ticket.price) {
            if([ticket.price intValue] > *highest) {
                *highest = [ticket.price intValue];
            }
            if([ticket.price intValue] < *lowest) {
                *lowest = [ticket.price intValue];
            }
        }
    }

    
}
@end
