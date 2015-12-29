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

@implementation newAccountViewController {
    int successfulCreation;
    UIActivityIndicatorView *spinner;
}

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
    self.username.delegate = self;
    
    self.password.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.password.layer.borderWidth = 1.2f;
    self.password.layer.cornerRadius = 8;
    self.password.clipsToBounds = YES;
    NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.password.attributedPlaceholder = str2;
    self.password.delegate = self;

    self.confirmPassword.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.confirmPassword.layer.borderWidth = 1.2f;
    self.confirmPassword.layer.cornerRadius = 8;
    self.confirmPassword.clipsToBounds = YES;
    NSAttributedString *str3 = [[NSAttributedString alloc] initWithString:@"Confirm Password" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.confirmPassword.attributedPlaceholder = str3;
    self.confirmPassword.delegate = self; 

}

-(IBAction)popController:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)createAccount:(id)sender {
    NSString *umichString = [[NSString alloc]init];
    if(self.username.text.length < 9) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Username Invalid" message:@"Make sure your username ends in @umich.edu" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
       umichString = [self.username.text substringFromIndex:[self.username.text length] - 9];
    }
    
    if(self.password.text.length < 8) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid password" message:@"Make sure your password is at least 8 characters long" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else if(![self.password.text isEqualToString: self.confirmPassword.text]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Passwords don't match" message:@"Make sure your passwords are the same" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else if(![umichString  isEqualToString: @"umich.edu"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Username Invalid" message:@"Make sure your username ends in @umich.edu" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSString *post = [NSString stringWithFormat:@"username=%@&password=%@", self.username.text, self.password.text];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *url = [NSString stringWithFormat:@"http://%@/create", serverAddress];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *error;
    
    spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center=CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/1.75);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"%@", response);
    NSLog(@"Created");
    [self login];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    
    NSDictionary *userData
    = [NSJSONSerialization JSONObjectWithData:mutData2
                                      options:kNilOptions
                                        error:&error];
    if(userData == NULL) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Account Creation Error" message:@"Could not create a count, try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        [spinner stopAnimating];
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

-(void)login{
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
        mutData2 = [NSMutableData data];
    }

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
