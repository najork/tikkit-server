//
//  ListingsTableCell.h
//  SellTicket
//
//  Created by Eric Yu on 11/4/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListingsTableCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *sectionLabel;
@property (nonatomic, strong) IBOutlet UILabel *sectionNumber;
@property (nonatomic, strong) IBOutlet UILabel *rowLabel;
@property (nonatomic, strong) IBOutlet UILabel *rowNumber;
@property (nonatomic, strong) IBOutlet UILabel *seatLabel;
@property (nonatomic, strong) IBOutlet UILabel *seatNumber;
@property (nonatomic, strong) IBOutlet UILabel *price; 

@property (nonatomic, strong) IBOutlet UIImageView *ticketImage;

@property (strong, nonatomic) id delegate;

@end

@protocol TicketTableCellProtocol <NSObject>

-(void)sendEmail;

@end