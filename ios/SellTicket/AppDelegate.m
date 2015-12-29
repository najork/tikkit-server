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
#import "buyingViewController.h"
#import "loginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //Initialize all the global dictionaries that I need access to
    ticketDictionary = [[NSMutableDictionary alloc]init];
    schoolDictionary = [[NSMutableDictionary alloc]init];
    gameDictionary = [[NSMutableDictionary alloc]init];
    gameIDToSchool = [[NSMutableDictionary alloc]init]; 
    
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"accessToken"]
        && [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"]) {
        
           accessToken  = [[NSUserDefaults standardUserDefaults]
                           stringForKey:@"accessToken"];
           user_id = [[NSUserDefaults standardUserDefaults]
                      stringForKey:@"user_id"];
              // So, here user already login then set your root view controller, let's say `SecondViewController``
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UINavigationController *buyingVC = [storyBoard instantiateViewControllerWithIdentifier:@"ticketContent"];
        // then set your root view controller
        self.window.rootViewController = buyingVC;
    }else {
        // It means you need to your root view controller is your login view controller, so let's create it
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UINavigationController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"loginContent"];

        self.window.rootViewController = loginVC;
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
