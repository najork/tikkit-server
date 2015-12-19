//
//  postTicketViewController.h
//  SellTicket
//
//  Created by Eric Yu on 10/31/15.
//  Copyright (c) 2015 myne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface postTicketViewController : UIViewController <UITextFieldDelegate>

//List of all the text fields
@property (nonatomic, strong) IBOutlet UITextField *section;
@property (nonatomic, strong) IBOutlet UITextField *row;
@property (nonatomic, strong) IBOutlet UITextField *seat;
@property (nonatomic, strong) IBOutlet UITextField *priceField;

@property (nonatomic, strong) IBOutlet UIButton *postTicket;
@property (nonatomic, strong) IBOutlet UILabel *numberOfTickets;
@property (nonatomic, strong) IBOutlet UILabel *highestPrice;
@property (nonatomic, strong) IBOutlet UILabel * lowestPrice;

@property (nonatomic) NSString *gameString;
@property (nonatomic) NSString *dateString;
@property (nonatomic) NSString *locationString;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) NSString *numTicketsString;
@property (nonatomic) NSString *highestPriceString;
@property (nonatomic) NSString *lowestPriceString;

@property (nonatomic, strong) IBOutlet UILabel *gameTitle;
@property (nonatomic, strong) IBOutlet UILabel *dateTime;
@property (nonatomic, strong) IBOutlet UILabel *location;
@property (nonatomic, strong) IBOutlet UIImageView *gameImage;
@property (nonatomic, strong) NSNumber *game_id;

@end
