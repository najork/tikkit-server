//
//  ticketClass.h
//  SellTicket
//
//  Created by Eric Yu on 11/4/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ticketClass : NSObject

@property (nonatomic, strong) NSString *section;
@property (nonatomic, strong) NSString *row;
@property (nonatomic, strong) NSString *seat;

//See if you want to use NSNumbers for price instead
@property (nonatomic, strong) NSString *price;

@end
