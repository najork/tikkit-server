//
//  newAccountViewController.m
//  SellTicket
//
//  Created by Eric Yu on 12/8/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import "newAccountViewController.h"
#import "global.h"

NSMutableData *mutData2;

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
    
    NSString *post = [NSString stringWithFormat:@"username=%@&password=%@", self.username.text, self.password.text];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *url = [NSString stringWithFormat:@"http://ec2-52-24-188-41.us-west-2.compute.amazonaws.com/create"];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    

    if(connection) {
        mutData2 = [NSMutableData data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[mutData2 length]);
    
    NSError *error;
    NSDictionary *userData
    = [NSJSONSerialization JSONObjectWithData:mutData2
                                      options:kNilOptions
                                        error:&error];
    
//    NSString *string = [userData objectForKey:@"token"];
//    accessToken = string;
//    
//    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ticketContent"];
//    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self presentViewController:vc animated:YES completion:nil];

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@\n", error.description);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [mutData2 setLength:0];
    NSLog(@"%@\n", response.description);
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mutData2 appendData:data];
}

@end
