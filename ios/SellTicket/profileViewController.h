//
//  profileViewController.h
//  SellTicket
//
//  Created by Eric Yu on 12/8/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface profileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *tickets;
@property (nonatomic, strong) IBOutlet UILabel *name;
@property ( nonatomic, strong) IBOutlet UILabel *email;
@property (nonatomic, strong) IBOutlet UILabel *phone;
@property (nonatomic) NSIndexPath *selectedIndex;

@property (nonatomic, strong) IBOutlet UITableView *ticketTable;
@end
