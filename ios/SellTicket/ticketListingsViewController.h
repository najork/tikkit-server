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
@property (nonatomic, strong) NSMutableArray *tickets;

@property (nonatomic, strong) IBOutlet UITableView *ticketTable; 

@property (nonatomic) NSString *gameString;
@property (nonatomic) NSString *dateString;
@property (nonatomic) NSString *locationString; 
@end
