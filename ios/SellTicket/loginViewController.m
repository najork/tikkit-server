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
    [self setupUI];
}

-(void) setupUI {
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
    self.username.delegate = self;
    self.password.delegate = self; 
    self.navigationController.navigationBarHidden = YES; 
}

-(IBAction)login:(id)sender {
    NSString *post = [NSString stringWithFormat:@"username=%@&password=%@", self.username.text, self.password.text];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *url = [NSString stringWithFormat:@"http://%@/login", serverAddress];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
