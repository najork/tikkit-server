//
//  serverFunctions.m
//  SellTicket
//
//  Created by Eric Yu on 12/25/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import "serverFunctions.h"
#import "Global.h"

@implementation serverFunctions

//Get is true, post is false
+(NSMutableDictionary *)serverAddress:(NSString *)server withRequestType:(BOOL)getOrPost {
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:server]
                                                          cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                      timeoutInterval: 10];
    getOrPost ? [request setHTTPMethod: @"GET"] : [request setHTTPMethod: @"POST"];
    
    // Set auth header
    NSString * bearerHeaderStr = @"Bearer ";
    [request setValue:[bearerHeaderStr stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSError *requestError = nil;
    NSURLResponse *urlResponse = nil;
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&urlResponse
                                                          error:&requestError];
    
    //If there is a response, we want to serialize it, otherwise, we return nil!
    NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc]init];
    if(response1) {
        responseDictionary = [NSJSONSerialization JSONObjectWithData:response1
                                                             options:kNilOptions
                                                               error:&requestError];
    } else {
        responseDictionary = nil; 
    }

    return responseDictionary;
}
@end
