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
#import "global.h"
#import "serverFunctions.h"

@interface ticketListingsViewController ()

@end

@implementation ticketListingsViewController {
    NSMutableDictionary *idToEmail;
}

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
    idToEmail = [[NSMutableDictionary alloc]init];
    _tickets = [[NSMutableArray alloc]init];
    self.view.backgroundColor = [UIColor yellowColor];
    [self setupTickets];
    [self setupEmails];
    [self setupUI];
}

-(void)setupEmails {
    for(ticketClass *ticket in self.tickets) {
        if([idToEmail objectForKey:ticket.seller_id]){
            continue;
        } else {
            NSString *userServerAddress
            = [NSString stringWithFormat: @"http://%@/api/users/%@", serverAddress, ticket.seller_id];
            
            NSMutableDictionary *userData = [serverFunctions serverAddress:userServerAddress withRequestType:GET];
            NSString *emailAddress = [userData objectForKey:@"username"];
            [idToEmail setObject:emailAddress forKey:ticket.seller_id];
        }
    }
    
}

-(void)sendEmail {
    ticketClass *selectedTicket = [self.tickets objectAtIndex:self.selectedIndex.row];
    NSString *emailAddress = [idToEmail objectForKey:selectedTicket.seller_id];
    NSString *url = [NSString stringWithFormat:@"mailto:%@", emailAddress];
    [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
}


-(void)setupTickets {
    self.tickets = [ticketDictionary objectForKey:self.game_id];
}

-(void)setupUI {
    UIBarButtonItem *systemItem1 = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back-0"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = systemItem1;
    
    _ticketTable.delegate = self;
    _ticketTable.dataSource = self;
    [_ticketTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.gameTitle.text = self.gameString;
    self.location.text = self.locationString;
    self.dateTime.text = self.dateString;
    self.gameImage.image = self.image;
    self.highestPrice.text = self.highestPriceString;
    self.lowestPrice.text = self.lowestPriceString;
    self.numberOfTickets.text = self.numTicketsString;

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
    static NSString *cellIdentifier = @"ListingsTableCell";
    
    ListingsTableCell *cell = (ListingsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListingsTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.delegate = self;
    }

    ticketClass *ticket = [self.tickets objectAtIndex:[indexPath row]];
    //Set the cell variables
    cell.price.text = [NSString stringWithFormat:@"$%@", ticket.price];
    if((NSNumber *)[NSNull null] != ticket.section) {
        cell.sectionNumber.text = [ticket.section stringValue];
    }
    
    if((NSNumber *)[NSNull null] != ticket.row) {
        cell.rowNumber.text = [ticket.row stringValue];
    }
    
    if((NSNumber *)[NSNull null] != ticket.seat) {
        cell.seatNumber.text = [ticket.seat stringValue];
    }
    cell.rowLabel.text = @"Row";
    cell.sectionLabel.text = @"Section";
    cell.seatLabel.text = @"Seat";
    cell.ticketImage.image = [UIImage imageNamed:@"buyTicket"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates]; // tell the table you're about to start making changes
    
    // If the index path of the currently expanded cell is the same as the index that
    // has just been tapped set the expanded index to nil so that there aren't any
    // expanded cells, otherwise, set the expanded index to the index that has just
    // been selected.
    if ([indexPath compare:self.selectedIndex] == NSOrderedSame) {
        self.selectedIndex = nil;
    } else {
        self.selectedIndex = indexPath;
    }
    
    [tableView endUpdates]; // tell the table you're done making your changes

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:self.selectedIndex] == NSOrderedSame) {
        return 360; // Expanded height
    }
    return 92;
}

@end
