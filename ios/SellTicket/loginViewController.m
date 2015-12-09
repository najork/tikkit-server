//
//  loginViewController.m
//  SellTicket
//
//  Created by Eric Yu on 12/8/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import "loginViewController.h"

@implementation loginViewController

-(void)viewDidLoad {
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
    NSString *serverAddress
    = @"http://ec2-52-24-188-41.us-west-2.compute.amazonaws.com:80/api/login?username=max&password=test";
    NSMutableURLRequest *request
    =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverAddress]
                             cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                         timeoutInterval: 10];
    
    [request setHTTPMethod: @"POST"];
    
    // Set auth header
//    NSString * bearerHeaderStr = @"Bearer ";
//    [request setValue:[bearerHeaderStr stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    
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
    
    NSLog(@"%@ is data", schools); 

}
@end
