//
//  buyingViewController.m
//  SellTicket
//
//  Created by Eric Yu on 10/11/15.
//  Copyright (c) 2015 myne. All rights reserved.
//

#import "buyingViewController.h"
#import "TicketTableCell.h"
#import "gameClass.h"
#import "ticketClass.h"
#import "ticketListingsViewController.h"
#import "global.h"


@implementation buyingViewController

-(void)viewDidLoad {
    [self setup];
}

-(void)viewDidAppear:(BOOL)animated {
    [self setup];
    [self.tableView reloadData];
}

-(void) setup {
    [self setupGames];
    
}

-(void)setupGames {
    gameClass *game1 = [[gameClass alloc]init];
    game1.gameTitle = @"Michigan vs. Rutgers";
    if([ticketDictionary objectForKey:game1.gameTitle]) {
        NSMutableArray *tickets = [ticketDictionary objectForKey:game1.gameTitle];
        int highestValue = -1;
        long int lowestValue = LONG_MAX;
        for(ticketClass *ticket in tickets) {
            if([ticket.price intValue] > highestValue) {
                highestValue = [ticket.price intValue];
            }
            if([ticket.price intValue] < lowestValue) {
                lowestValue = [ticket.price intValue];
            }
            NSLog(@"%@, %i, %li", ticket.price, highestValue, lowestValue);
        }
        game1.lowPrice = [NSString stringWithFormat: @"$%li", lowestValue];
        game1.highPrice = [NSString stringWithFormat:@"$%i", highestValue];
        game1.numTickets = [NSString stringWithFormat:@"%lu listed", (unsigned long)[tickets count]];
        game1.gameDate = @"Nov. 2nd";
    } else {
        game1.lowPrice = @"$0";
        game1.highPrice = @"$0";
        game1.numTickets = @"0 listed";
        game1.gameDate = @"Nov. 2nd";
    }
    
    
    gameClass *game2 = [[gameClass alloc]init];
    game2.gameTitle = @"Michigan vs. Ohio State";
    
    if([ticketDictionary objectForKey:game2.gameTitle]) {
        NSMutableArray *tickets = [ticketDictionary objectForKey:game2.gameTitle];
        int highestValue = -1;
        long int lowestValue = LONG_MAX;
        for(ticketClass *ticket in tickets) {
            if([ticket.price intValue] > highestValue) {
                highestValue = [ticket.price intValue];
            }
            if([ticket.price intValue] < lowestValue) {
                lowestValue = [ticket.price intValue];
            }
            NSLog(@"%@, %i, %li", ticket.price, highestValue, lowestValue);
        }
        game2.lowPrice = [NSString stringWithFormat: @"$%li", lowestValue];
        game2.highPrice = [NSString stringWithFormat:@"$%i", highestValue];
        game2.numTickets = [NSString stringWithFormat:@"%lu listed", (unsigned long)[tickets count]];
        game2.gameDate = @"Nov. 16th";
    } else {
        game2.lowPrice = @"$0";
        game2.highPrice = @"$0";
        game2.numTickets = @"0 listed";
        game2.gameDate = @"Nov. 16th";
    }
   
    
    gameClass *game3 = [[gameClass alloc]init];
    game3.gameTitle = @"Michigan vs. Minnesota";
    if([ticketDictionary objectForKey:game3.gameTitle]) {
        NSMutableArray *tickets = [ticketDictionary objectForKey:game3.gameTitle];
        int highestValue = -1;
        long int lowestValue = LONG_MAX;
        for(ticketClass *ticket in tickets) {
            if([ticket.price intValue] > highestValue) {
                highestValue = [ticket.price intValue];
            }
            if([ticket.price intValue] < lowestValue) {
                lowestValue = [ticket.price intValue];
            }
            NSLog(@"%@, %i, %li", ticket.price, highestValue, lowestValue);
        }
        game3.lowPrice = [NSString stringWithFormat: @"$%li", lowestValue];
        game3.highPrice = [NSString stringWithFormat:@"$%i", highestValue];
        game3.numTickets = [NSString stringWithFormat:@"%lu listed", (unsigned long)[tickets count]];
        game3.gameDate = @"Nov. 23rd";
    } else {
        game3.lowPrice = @"$0";
        game3.highPrice = @"$0";
        game3.numTickets = @"0 listed";
        game3.gameDate = @"Nov. 23rd";
    }

    
    self.games = [[NSMutableArray alloc]init];
    [self.games addObject:game1];
    [self.games addObject:game2];
    [self.games addObject:game3];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //count number of row from counting array hear cataGorry is An Array
    return [_games count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    TicketTableCell *cell = (TicketTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TicketTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    gameClass *game = [self.games objectAtIndex:[indexPath row]];
    cell.highPrice.image = [UIImage imageNamed:@"max-price"];
    cell.lowPrice.image = [UIImage imageNamed:@"low-price"];
    cell.numTickets.image = [UIImage imageNamed:@"buy-tickets"];
    cell.gameTitle.text = game.gameTitle;
    cell.highPriceLabel.text = game.highPrice;
    cell.lowPriceLabel.text = game.lowPrice;
    cell.numTicketsLabel.text = game.numTickets;
    
    if([indexPath row] % 3 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:0.97 green:0.95 blue:0.15 alpha:1.0];
    } else if ([indexPath row] % 3 == 1) {
        cell.backgroundColor = [UIColor colorWithRed:0.26 green:0.28 blue:0.29 alpha:1.0];
        cell.gameTitle.textColor = [UIColor whiteColor];
        cell.highPriceLabel.textColor = [UIColor whiteColor];
        cell.lowPriceLabel.textColor = [UIColor whiteColor];
        cell.numTicketsLabel.textColor = [UIColor whiteColor];

    } else {
        cell.backgroundColor = [UIColor whiteColor]; 
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath;
    [self performSegueWithIdentifier:@"ticketSegue" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180;
}

//Segue from vc to vc, triggered by selecting a cell
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"ticketSegue"]){
        ticketListingsViewController *vc = [segue destinationViewController];
        NSInteger selectedRow = self.selectedIndex.row;
        gameClass *game = [self.games objectAtIndex:selectedRow];
        vc.gameString = game.gameTitle;
        vc.dateString = game.gameDate;
        vc.locationString = @"Michigan Stadium"; 
    }
}


@end
