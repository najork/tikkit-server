//
//  ticketListingsViewController.h
//  SellTicket
//
//  Created by Eric Yu on 11/4/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ticketListingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *gameTitle;
@property (nonatomic, strong) IBOutlet UILabel *dateTime;
@property (nonatomic, strong) IBOutlet UILabel *location;
@property (nonatomic, strong) IBOutlet UIImageView *gameImage;

@property (nonatomic, strong) IBOutlet UILabel *numberOfTickets;
@property (nonatomic, strong) IBOutlet UILabel *highestPrice;
@property (nonatomic, strong) IBOutlet UILabel * lowestPrice;

@property (nonatomic, strong) IBOutlet UITableView *ticketTable;
@property (nonatomic, strong) NSMutableArray *tickets;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, strong) NSNumber *game_id; 

@property (nonatomic) NSString *gameString;
@property (nonatomic) NSString *dateString;
@property (nonatomic) NSString *locationString;
@property (nonatomic) NSString *numTicketsString;
@property (nonatomic) NSString *highestPriceString;
@property (nonatomic) NSString *lowestPriceString; 
@property (nonatomic, strong) UIImage *image;

@end
