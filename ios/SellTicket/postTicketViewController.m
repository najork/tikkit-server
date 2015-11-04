//
//  postTicketViewController.m
//  SellTicket
//
//  Created by Eric Yu on 10/31/15.
//  Copyright (c) 2015 myne. All rights reserved.
//

#import "postTicketViewController.h"
#import "textFieldKeyboardShift.h"

@implementation postTicketViewController {
    UIPickerView *picker;
    NSMutableArray *games;
}

-(void) viewDidLoad{
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
    //Do some code in here to post the data we have into the database
    
}

//Add games into the games array. Might pull available
//games from database??
-(void)populateGames {
    /*NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL
                                         URLWithString:http://localhost:8080/api/school/:id]
                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:10
                                         ];
     
    [request setHTTPMethod: @"GET"];
    NSError *requestError = nil;
    NSURLResponse *urlResponse = nil;
    
    
    NSData *response1 =
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&urlResponse error:&requestError];
     */
    
    games = [[NSMutableArray alloc]init];
    [games addObject:@"Michigan vs. Rutgers 11/7"];
    [games addObject:@"Michigan vs. Ohio State 11/28"];
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
    self.gameField.text = [games objectAtIndex:row];
}



@end
