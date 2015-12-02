//
//  singleTicketViewController.m
//  SellTicket
//
//  Created by Eric Yu on 11/4/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import "singleTicketViewController.h"

@interface singleTicketViewController ()

@end

@implementation singleTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    // Do any additional setup after loading the view.
}

-(void) setup {
    //This line isn't necessary. Changed in the IB already. 
    self.view.backgroundColor = [UIColor yellowColor];
    self.gameLabel.text = self.gameString;
    self.dateLabel.text = self.dateString;
    self.locationLabel.text = self.locationString;
    self.sectionNumber.text = [self.sectionString stringValue];
    self.rowNumber.text = [self.rowString stringValue];
    self.seatNumber.text = [self.seatString stringValue];
    self.price.text = [self.priceString stringValue];
    self.ticketImage.image = [UIImage imageNamed:@"buy-tickets"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) callBuyer:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://18457023425"]];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
