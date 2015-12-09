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
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel; 

@property (nonatomic, strong) IBOutlet UIImageView *numTickets;
@property (nonatomic, strong) IBOutlet UIImageView *gameImage;

@property (nonatomic, strong) IBOutlet UIButton *postTicket;
@property (nonatomic, strong) IBOutlet UIButton *sellTicket; 

//Need to keep track of a delegate for the table cell to pass information to
@property (strong, nonatomic) id delegate;

@end

@protocol TicketTableCellProtocol <NSObject>

-(void)buyOrSellSegue:(BOOL) buyOrSell;

@end