//
//  TicketTableCell.m
//  SellTicket
//
//  Created by Eric Yu on 11/4/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import "TicketTableCell.h"

@implementation TicketTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//Set the value of buy or sell segue to YES because
//1 will represent posting a ticket
-(IBAction)postTicket:(id)sender {
    NSLog(@"%@", self.delegate);
    [self.delegate buyOrSellSegue: YES];
}


//Set the value of buy or sell segue to NO
//so 0 will represent viewing tickets
-(IBAction)viewTickets:(id)sender {
    [self.delegate buyOrSellSegue: NO];
}
@end
