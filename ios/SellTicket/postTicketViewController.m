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
    UIPickerView *picker;
    NSMutableArray *games;
    NSNumber *game_id;
    NSMutableArray *game_ids;
    UIActivityIndicatorView *spinner;
}

-(void) viewDidLoad{
    game_id = [[NSNumber alloc]init];
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
    
    //Setup the UIPickerView (for the game selection)
    picker = [[UIPickerView alloc]init];
    [picker setDataSource:self];
    [picker setDelegate:self];
    picker.showsSelectionIndicator = YES;
    self.gameField.inputView = picker;
    [picker selectRow:0 inComponent:0 animated:NO];
    
    //Add a tap gesture to close the keyboard
    //when we tap outside of the keyboard view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [self populateGames];
    [self setupPicker];
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
    
    NSString *post = [NSString stringWithFormat:@"http://ec2-52-24-188-41.us-west-2.compute.amazonaws.com/api/games/%@/tickets/create?section=%@&row=%@&seat=%@&price=%@", @"1", section, row, seat, price];
    NSURL *postURL = [NSURL URLWithString:post];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:postURL
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:10];
    
    
    [request setHTTPMethod: @"POST"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
    if(connection) {
        mutData = [NSMutableData data];
    }
    
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
    NSString *str = [[NSString alloc] initWithData:mutData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", str);
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

//Code for the UIPickerView delegate
-(void) setupPicker {
    UIToolbar*  mypickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    mypickerToolbar.barStyle = UIBarStyleDefault;
    [mypickerToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked)];
    [barItems addObject:doneBtn];
    [mypickerToolbar setItems:barItems animated:YES];
    self.gameField.inputAccessoryView = mypickerToolbar;
}

-(void)pickerDoneClicked{
    [self.gameField resignFirstResponder];
}

//This function returns the number of rows there are in the PickerView. This depends on the number
//of games there are that can be selected.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [games count];
}

//We will only return one component per pickerview.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

//Return the title of every object from the games array
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [games objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    game_id = [game_ids objectAtIndex:row];
    self.gameField.text = [games objectAtIndex:row];
    [self updateData];
}

-(void)updateData {
    if([ticketDictionary objectForKey:game_id]) {
        NSMutableArray *tickets = [ticketDictionary objectForKey:game_id];
        self.numberOfTickets.text = [NSString stringWithFormat: @"%lu",(unsigned long)[tickets count]];
        
        int highestValue = -1;
        long int lowestValue = LONG_MAX;
        for(ticketClass *ticket in tickets) {
            if((NSNumber *)[NSNull null] != ticket.price) {
                if([ticket.price intValue] > highestValue) {
                    highestValue = [ticket.price intValue];
                }
                if([ticket.price intValue] < lowestValue) {
                    lowestValue = [ticket.price intValue];
                }
            }
        }
        
        self.lowestPrice.text = [NSString stringWithFormat: @"$%li", lowestValue];
        self.highestPrice.text = [NSString stringWithFormat: @"$%i", highestValue];
    } else {
        self.numberOfTickets.text = @"0";
        self.lowestPrice.text = @"N/A";
        self.highestPrice.text = @"N/A";
    }
}


@end
