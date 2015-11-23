//
//  AppDelegate.m
//  SellTicket
//
//  Created by Eric Yu on 10/6/15.
//  Copyright (c) 2015 myne. All rights reserved.
//

#import "AppDelegate.h"
#import "global.h"
#import "ticketClass.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //Initialize all the global dictionaries that I need access to
    ticketDictionary = [[NSMutableDictionary alloc]init];
    schoolDictionary = [[NSMutableDictionary alloc]init];
    gameDictionary = [[NSMutableDictionary alloc]init];
    
    //Whenever the application loads, make a request to acquire a list of all the schools
    //Get the object as a JSON Dictionary
    NSString *serverAddress
        = @"http://ec2-52-24-188-41.us-west-2.compute.amazonaws.com:80/api/lists/schools";
    NSMutableURLRequest *request
        =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverAddress]
                                 cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                             timeoutInterval: 10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError = nil;
    NSURLResponse *urlResponse = nil;
    NSData *response1
        = [NSURLConnection sendSynchronousRequest:request
                                returningResponse:&urlResponse
                                            error:&requestError];
    
    NSDictionary *schools
        = [NSJSONSerialization JSONObjectWithData:response1
                                          options:kNilOptions
                                            error:&requestError];

    
    //Iterate through all of the school names and put them into
    //the schoolDictionary global variable.
    for(NSDictionary *school in schools) {
        NSNumber * school_id = [school objectForKey:@"school_id"];
        NSString * school_name = [school objectForKey:@"name"];
        [schoolDictionary setObject:school_name forKey:school_id];
        
        //For every school, we also want to load in a list of all the games
        //that correspond to school
        serverAddress
            = [NSString stringWithFormat:@"http://ec2-52-24-188-41.us-west-2.compute.amazonaws.com/api/lists/schools/%@/games", school_id];
        
        request = [NSMutableURLRequest requestWithURL:[NSURL
                                                       URLWithString:serverAddress]
                                          cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                      timeoutInterval:10];
        [request setHTTPMethod:@"GET"];
        requestError = nil;
        urlResponse = nil;
        
        response1
            = [NSURLConnection sendSynchronousRequest:request
                                    returningResponse:&urlResponse
                                                error:&requestError];
        
        id jsonDictionary2 = [[NSMutableDictionary alloc]init];
        jsonDictionary2
            = [NSJSONSerialization JSONObjectWithData:response1
                                              options:kNilOptions
                                                error:&requestError];
        
        //Set a list of games for every school
        [gameDictionary setObject:jsonDictionary2 forKey:school_id];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
