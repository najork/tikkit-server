//
//  loginViewController.m
//  SellTicket
//
//  Created by Eric Yu on 12/8/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import "loginViewController.h"
#import "global.h"
#import "KeychainItemWrapper.h"

@implementation loginViewController

NSMutableData *mutableData;

-(void)viewDidLoad {
    if([keychainItem objectForKey:(__bridge id)kSecValueData]
       && [keychainItem objectForKey:(__bridge id)kSecAttrAccount]) {
        accessToken  = [[NSUserDefaults standardUserDefaults]
                                        stringForKey:@"accessToken"];
        user_id = [[NSUserDefaults standardUserDefaults]
                                                  stringForKey:@"user_id"];
        UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ticketContent"];
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:vc animated:YES completion:nil];
    }
    [self setup];
}

-(void) setup {
    self.username.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.username.layer.borderWidth = 1.2f;
    self.username.layer.cornerRadius = 8;
    self.username.clipsToBounds = YES;
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Login ID" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.username.attributedPlaceholder = str;
   
    self.password.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.password.layer.borderWidth = 1.2f;
    self.password.layer.cornerRadius = 8;
    self.password.clipsToBounds = YES;
    NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.password.attributedPlaceholder = str2;
    
    self.navigationController.navigationBarHidden = YES; 
}

-(IBAction)login:(id)sender {
    NSLog(@"%@ is user and %@ is pass", self.username.text, self.password.text);
    NSString *post = [NSString stringWithFormat:@"username=%@&password=%@", self.username.text, self.password.text];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *url = [NSString stringWithFormat:@"http://ec2-52-24-188-41.us-west-2.compute.amazonaws.com/login"];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    
    // Set auth header
//    NSString * bearerHeaderStr = @"Bearer ";
//    [request setValue:[bearerHeaderStr stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
    if(connection) {
        mutableData = [NSMutableData data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    
    NSDictionary *userData
    = [NSJSONSerialization JSONObjectWithData:mutableData
                                      options:kNilOptions
                                        error:&error];
    if(userData == NULL) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Login Error" message:@"Your login parameters were incorrect, try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return; 
    }
    NSString *token = [userData objectForKey:@"token"];
    NSString *userID = [userData objectForKey:@"user_id"];
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"user_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"loginToApp" accessGroup:nil];
    [keychainItem setObject:self.username.text forKey:(__bridge id)kSecValueData];
    [keychainItem setObject:self.password.text forKey:(__bridge id)kSecAttrAccount];
    accessToken = token;
    user_id = userID;
    
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ticketContent"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@\n", error.description);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [mutableData setLength:0];
    NSLog(@"%@\n", response.description);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mutableData appendData:data];
    
}

@end
