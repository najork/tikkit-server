//
//  postTicketViewController.m
//  SellTicket
//
//  Created by Eric Yu on 10/31/15.
//  Copyright (c) 2015 myne. All rights reserved.
//

#import "postTicketViewController.h"
#import "textFieldKeyboardShift.h"
#import "global.h"
#import "ticketClass.h"

NSMutableData *mutData;

@implementation postTicketViewController {
    //UIPickerView *picker;
    NSMutableArray *games;
    NSMutableArray *game_ids;
    UIActivityIndicatorView *spinner;
}

-(void) viewDidLoad{
    game_ids = [[NSMutableArray alloc]init];
    [self setup];
}

-(void) setup {
    [self.postTicket.layer setCornerRadius:5.0f];
    self.postTicket.clipsToBounds = YES;
    
    //Set tags on all the textfields so we know which one to use
    //inside the delegate functions.
    self.priceField.tag = 1;
    self.section.tag = 2;
    self.row.tag = 3;
    self.seat.tag = 4;
    
    //Set the delegate of all the textfields to this viewcontroller.
    self.priceField.delegate = self;
    self.section.delegate = self;
    self.row.delegate = self;
    self.seat.delegate = self;
    
    //Add a tap gesture to close the keyboard
    //when we tap outside of the keyboard view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    self.gameImage.image = self.image;
    self.gameTitle.text = self.gameString;
    self.location.text = self.locationString;
    self.dateTime.text = self.dateString;
    self.highestPrice.text = self.highestPriceString;
    self.lowestPrice.text = self.lowestPriceString;
    self.numberOfTickets.text = self.numTicketsString;
    
    UIBarButtonItem *systemItem1 = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back-0"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = systemItem1;
    
    [self populateGames];
}

-(IBAction)postTicket:(id)sender {
    //Do error checking. Make sure there are values
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Parameter" message:@"Please make sure you enter a price, row, seat, and section!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    //Make sure all the spots are filled in
    if([self.section.text isEqualToString:@""]) {
        [alert show];
        return;
    }
    if([self.row.text isEqualToString:@""]) {
        [alert show];
        return;
    }
    if([self.seat.text isEqualToString:@""]) {
        [alert show];
        return;
    }
    if([self.priceField.text isEqualToString:@""]) {
        [alert show];
        return;
    }
    
    //Do some code in here to post the data we have into the database
    NSString *section = self.section.text;
    NSString *row = self.row.text;
    NSString *seat = self.seat.text;
    NSString *price = self.priceField.text;

    NSString *post = [NSString stringWithFormat:@"section=%@&row=%@&seat=%@&price=%@", section, row, seat, price];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];

    NSString *url = [NSString stringWithFormat:@"http://%@/api/games/%@/tickets/create", serverAddress, self.game_id];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:10];

    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    // Set auth header
    NSString * bearerHeaderStr = @"Bearer ";
    [request setValue:[bearerHeaderStr stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
    if(connection) {
        mutData = [NSMutableData data];
    }
    [self updateData]; 
};


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Your ticket has been posted" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    self.section.text = @"";
    self.row.text = @"";
    self.seat.text = @"";
    self.priceField.text = @"";
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[mutData length]);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@\n", error.description);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [mutData setLength:0];
    NSLog(@"%@\n", response.description);
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mutData appendData:data];
}

//Add games into the games array. Might pull available
//games from database??
-(void)populateGames {
    games = [[NSMutableArray alloc]init];
    
    //Only need to account for Michigan for now.
    NSNumber *home_id = @1;
    NSMutableArray *gameOfArrays = [gameDictionary objectForKey:home_id];
    NSString *home_team_name = [schoolDictionary objectForKey:home_id];
    for(id game in gameOfArrays) {
        NSString *away_team_id = [game objectForKey:@"away_team_id"];
        NSString *away_team_name = [schoolDictionary objectForKey:away_team_id];
        NSNumber *temp_game_id = [game objectForKey:@"game_id"];
        [games addObject:[NSString stringWithFormat:@"%@ vs. %@", home_team_name, away_team_name]];
        [game_ids addObject:temp_game_id];
    }
}



-(void)dismissKeyboard {
    [self.view scrollToView:0];
    [self.priceField resignFirstResponder];
}

//Text field delegate functions
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag == 1) {
        [self.view scrollToView:textField];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self.view scrollToView:0];
    [textField resignFirstResponder];
    return YES;
}

-(void)updateData {
    
    NSString *lowPriceString = @"$0";
    NSString *highPriceString = @"$0";
    NSString *ticketCount = @"0";

    if([ticketDictionary objectForKey:self.game_id]) {
        NSMutableArray *tickets = [ticketDictionary objectForKey:self.game_id];
        int highestValue = -1;
        int lowestValue = INT_MAX;
        
        [ticketClass calculateHighest:&highestValue andLowest:&lowestValue inTickets:tickets];
        
        lowPriceString = [NSString stringWithFormat: @" $%i", lowestValue];
        highPriceString = [NSString stringWithFormat:@" $%i", highestValue];
        ticketCount = [NSString stringWithFormat:@" %lu",(unsigned long)[tickets count]];
    }
    
    self.lowestPrice.text = [@"Lowest: " stringByAppendingString:lowPriceString];
    self.highestPrice.text = [@"Highest: " stringByAppendingString:highPriceString];
    self.numberOfTickets.text = [NSString stringWithFormat:@" %@ listed", ticketCount];
}


@end
