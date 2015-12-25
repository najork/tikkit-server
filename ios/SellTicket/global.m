//
//  global.m
//  SellTicket
//
//  Created by Eric Yu on 11/11/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "global.h"

NSMutableDictionary * ticketDictionary;
NSMutableDictionary * schoolDictionary;
NSMutableDictionary * gameDictionary;
NSMutableDictionary *gameIDToSchool;

NSString * accessToken;
NSString * user_id;
NSString * serverAddress = @"ec2-52-35-223-115.us-west-2.compute.amazonaws.com";

int GET = 1;
int POST = 0; 