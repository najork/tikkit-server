//
//  TicketTableCell.h
//  SellTicket
//
//  Created by Eric Yu on 11/4/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TicketTableCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *gameTitle;
@property (nonatomic, strong) IBOutlet UILabel *highPriceLabel;
@property (nonatomic, strong) IBOutlet UILabel *lowPriceLabel;
@property (nonatomic, strong) IBOutlet UILabel *numTicketsLabel;

@property (nonatomic, strong) IBOutlet UIImageView *highPrice;
@property (nonatomic, strong) IBOutlet UIImageView *lowPrice;
@property (nonatomic, strong) IBOutlet UIImageView *numTickets;





@end
