//
//  singleTicketViewController.h
//  SellTicket
//
//  Created by Eric Yu on 11/4/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface singleTicketViewController : UIViewController

@property (nonatomic) NSString *gameString;
@property (nonatomic) NSString *dateString;
@property (nonatomic) NSString *locationString;

@property (nonatomic, strong) IBOutlet UILabel *gameLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;


//Ticket IBOutlets
@property (nonatomic, strong) IBOutlet UILabel *sectionLabel;
@property (nonatomic, strong) IBOutlet UILabel *sectionNumber;
@property (nonatomic, strong) IBOutlet UILabel *rowLabel;
@property (nonatomic, strong) IBOutlet UILabel *rowNumber;
@property (nonatomic, strong) IBOutlet UILabel *seatLabel;
@property (nonatomic, strong) IBOutlet UILabel *seatNumber;
@property (nonatomic, strong) IBOutlet UILabel *price;

@property (nonatomic, strong) IBOutlet UIImageView *ticketImage;

@property (nonatomic, strong) NSString *priceString; 
@property (nonatomic, strong) NSString *sectionString;
@property (nonatomic, strong) NSString *rowString;
@property (nonatomic, strong) NSString *seatString;
@end
