//
//  postTicketViewController.h
//  SellTicket
//
//  Created by Eric Yu on 10/31/15.
//  Copyright (c) 2015 myne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface postTicketViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

//List of all the text fields
@property(nonatomic, strong) IBOutlet UITextField *gameField;
@property (nonatomic, strong) IBOutlet UITextField *section;
@property (nonatomic, strong) IBOutlet UITextField *row;
@property (nonatomic, strong) IBOutlet UITextField *seat;
@property (nonatomic, strong) IBOutlet UITextField *priceField;




@property (nonatomic, strong) IBOutlet UIButton *postTicket;
@property (nonatomic, strong) IBOutlet UILabel *numberOfTickets;
@property (nonatomic, strong) IBOutlet UILabel *highestPrice;
@property (nonatomic, strong) IBOutlet UILabel * lowestPrice;

@end
