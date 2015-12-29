//
//  serverFunctions.h
//  SellTicket
//
//  Created by Eric Yu on 12/25/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface serverFunctions : NSObject

+(NSMutableDictionary *)serverAddress:(NSString *)server withRequestType:(BOOL)getOrPost;

@end
