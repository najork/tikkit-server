//
//  newAccountViewController.m
//  SellTicket
//
//  Created by Eric Yu on 12/8/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import "newAccountViewController.h"

@implementation newAccountViewController

-(void)viewDidLoad {
    [self setup];
}

-(void)setup {
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

    self.confirmPassword.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.confirmPassword.layer.borderWidth = 1.2f;
    self.confirmPassword.layer.cornerRadius = 8;
    self.confirmPassword.clipsToBounds = YES;
    NSAttributedString *str3 = [[NSAttributedString alloc] initWithString:@"Confirm Password" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.confirmPassword.attributedPlaceholder = str3;

}

-(IBAction)popController:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)createAccount:(id)sender {
    NSString *serverAddress
    = [NSString stringWithFormat:@"http://ec2-52-24-188-41.us-west-2.compute.amazonaws.com:80/api/create?username=%@&password=%@", self.username.text, self.password.text];
    NSMutableURLRequest *request
    =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverAddress]
                             cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                         timeoutInterval: 10];
    
    [request setHTTPMethod: @"POST"];
    NSError *requestError = nil;
    NSURLResponse *urlResponse = nil;
    NSData *response1
    = [NSURLConnection sendSynchronousRequest:request
                            returningResponse:&urlResponse
                                        error:&requestError];

    NSLog(@"%@", response1);
}
@end
