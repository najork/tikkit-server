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
#import "ticketListingsViewController.h"


@implementation buyingViewController

-(void)viewDidLoad {
    [self setup];
}

-(void) setup {
    [self setupGames];
}

-(void)setupGames {
    gameClass *game1 = [[gameClass alloc]init];
    game1.gameTitle = @"Michigan vs. Rutgers";
    game1.lowPrice = @"$40";
    game1.highPrice = @"$150";
    game1.numTickets = @"126 listed";
    
    gameClass *game2 = [[gameClass alloc]init];
    game2.gameTitle = @"Michigan vs. Ohio State";
    game2.lowPrice = @"$40";
    game2.highPrice = @"$150";
    game2.numTickets = @"90 listed";
    
    gameClass *game3 = [[gameClass alloc]init];
    game3.gameTitle = @"Michigan vs. Minnesota";
    game3.lowPrice = @"$40";
    game3.highPrice = @"$150";
    game3.numTickets = @"26 listed";
    
    NSLog(@"%@", game1);
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
        vc.locationString = @"Michigan Stadium"; 
    }
}


@end
