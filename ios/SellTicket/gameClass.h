//
//  gameClass.h
//  SellTicket
//
//  Created by Eric Yu on 10/11/15.
//  Copyright (c) 2015 myne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface gameClass : NSObject

@property (nonatomic, strong) NSString *gameTitle;
@property (nonatomic, strong) NSString *lowPrice;
@property (nonatomic, strong) NSString *highPrice;
@property (nonatomic, strong) NSString *numTickets;
@property (nonatomic, strong) NSString *gameDate;
@property (nonatomic, strong) NSNumber *game_id; 

@end
