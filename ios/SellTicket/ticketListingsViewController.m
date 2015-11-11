//
//  ticketListingsViewController.m
//  SellTicket
//
//  Created by Eric Yu on 11/4/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import "ticketListingsViewController.h"
#import "ticketClass.h"
#import "ListingsTableCell.h"
#import "singleTicketViewController.h"
#import "global.h"

@interface ticketListingsViewController ()

@end

@implementation ticketListingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setup {
    _tickets = [[NSMutableArray alloc]init];
    self.view.backgroundColor = [UIColor yellowColor];
    [self setupTickets];
  
    _ticketTable.delegate = self;
    _ticketTable.dataSource = self;
    self.gameTitle.text = self.gameString;
    self.location.text = self.locationString;
    self.dateTime.text = self.dateString; 
}

-(void)setupTickets {
    self.tickets = [ticketDictionary objectForKey:self.gameString]; 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //count number of row from counting array hear cataGorry is An Array
    return [_tickets count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Got here");
    static NSString *cellIdentifier = @"ListingsTableCell";
    
    ListingsTableCell *cell = (ListingsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListingsTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    
    
    ticketClass *ticket = [self.tickets objectAtIndex:[indexPath row]];
    NSLog(@"%@", ticket.price);
    //Set the cell variables
    cell.price.text = [NSString stringWithFormat:@"$%@", ticket.price];
    cell.sectionNumber.text = ticket.section;
    cell.rowNumber.text = ticket.row;
    cell.seatNumber.text = ticket.seat;
    cell.rowLabel.text = @"Row";
    cell.sectionLabel.text = @"Section";
    cell.seatLabel.text = @"Seat";
    cell.ticketImage.image = [UIImage imageNamed:@"buy-tickets"];
 
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath;
    [self performSegueWithIdentifier:@"singleTicketSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    singleTicketViewController *destinationVC = [segue destinationViewController];
    destinationVC.gameString = self.gameString;
    destinationVC.dateString = self.dateString;
    destinationVC.locationString = self.locationString;
    
    ticketClass *ticket = [self.tickets objectAtIndex:[self.selectedIndex row]];
    
    destinationVC.sectionString = ticket.section;
    destinationVC.rowString = ticket.row;
    destinationVC.seatString = ticket.seat;
    destinationVC.priceString = ticket.price; 
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
