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


@implementation buyingViewController {
}

-(void)viewDidLoad {
    //Maybe I don't have to do anything in here? Just do in ViewDidAppear?
    //   [self setup];
}

-(void)viewDidAppear:(BOOL)animated {
    [self setup];
    [self.tableView reloadData];
}

-(void) setup {
    [self setupTickets];
    [self setupGames];
}

-(void) setupTickets {
    //Now load in all the tickets that are currently in the server. Might not be the smart way
    //Default is setting the ticket access to 1 for Michigan
    NSString *ticketServerAddress
        = @"http://ec2-52-24-188-41.us-west-2.compute.amazonaws.com:80/api/games/1/tickets";
    
    NSMutableURLRequest *request
        = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ticketServerAddress]
                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                              timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];

    // Set auth header
    NSString * bearerHeaderStr = @"Bearer ";
    [request setValue:[bearerHeaderStr stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSError *requestError = nil;
    NSURLResponse *urlResponse = nil;
    NSData *ticketResponse
        = [NSURLConnection sendSynchronousRequest:request
                                returningResponse:&urlResponse
                                            error:&requestError];
    
    NSDictionary *tickets
        = [NSJSONSerialization JSONObjectWithData:ticketResponse
                                          options:kNilOptions
                                            error:&requestError];
    
    //Currently need to reload every ticket every time
    for(id ticket in tickets) {
        ticketClass *newTicket = [[ticketClass alloc] init];
        newTicket.section = [ticket objectForKey:@"section"];
        newTicket.row = [ticket objectForKey:@"row"];
        newTicket.price = [ticket objectForKey:@"price"];
        newTicket.seat = [ticket objectForKey:@"seat"];
        newTicket.ticket_id = [ticket objectForKey:@"ticket_id"];
        NSNumber *game_id = [ticket objectForKey:@"game_id"];

        
        if([ticketDictionary objectForKey:game_id]) {
            NSMutableArray *array = [ticketDictionary objectForKey:game_id];
            
            //If ticket already exists, we continue. If not, we add to the
            //array
            BOOL exists = NO;
            for(ticketClass *ticket in array) {
                if([ticket.ticket_id intValue] == [newTicket.ticket_id intValue]) {
                    exists = YES;
                    break;
                }
            }
            if(exists) {
                continue;
            }
            
            [array addObject:newTicket];
        } else {
            NSMutableArray *newArray = [[NSMutableArray alloc]init];
            [newArray addObject:newTicket];
            [ticketDictionary setObject:newArray forKey:game_id];
        }
    }

}

-(void)setupGames {
    self.games = [[NSMutableArray alloc]init];
    
    NSNumber *homeTeam = @1;
    NSMutableArray *gameOfArrays = [gameDictionary objectForKey:homeTeam];
    NSLog(@"%@ is the array", gameOfArrays);
    
    for(id game in gameOfArrays) {
        gameClass *newGame = [[gameClass alloc]init];
        
        NSNumber *game_id = [game objectForKey:@"game_id"];
        NSString *away_id = [game objectForKey:@"away_team_id"];
        
        //Find the highest priced/lowest priced tickets.
        //Split this into a different function later on.
        if([ticketDictionary objectForKey:game_id]) {
            NSMutableArray *tickets = [ticketDictionary objectForKey:game_id];
            int highestValue = -1;
            long int lowestValue = LONG_MAX;
            for(ticketClass *ticket in tickets) {
                if((NSNumber *)[NSNull null] != ticket.price) {
                    if([ticket.price intValue] > highestValue) {
                        highestValue = [ticket.price intValue];
                    }
                    if([ticket.price intValue] < lowestValue) {
                        lowestValue = [ticket.price intValue];
                    }
                }
                NSLog(@"%@, %i, %li", ticket.price, highestValue, lowestValue);
            }
            NSString *lowPriceString = [NSString stringWithFormat: @" $%li", lowestValue];
            NSString *highPriceString = [NSString stringWithFormat:@" $%i", highestValue];
            
            newGame.lowPrice = [@"Lowest: " stringByAppendingString:lowPriceString];
            newGame.highPrice = [@"Highest: " stringByAppendingString:highPriceString];
            newGame.numTickets = [NSString stringWithFormat:@" %lu listed", (unsigned long)[tickets count]];
        } else {
            newGame.lowPrice = @"Lowest: $0";
            newGame.highPrice = @"Highest: $0";
            newGame.numTickets = @"0 listed";
        }
        
        
        newGame.gameTitle = [schoolDictionary objectForKey:away_id];
        newGame.gameDate = [game objectForKey:@"date"];
        
        [self.games addObject:newGame];
    }
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
        cell.delegate = self;
    }
    
    gameClass *game = [self.games objectAtIndex:[indexPath row]];
    
    cell.locationLabel.text = @"Michigan Stadium";
    cell.timeLabel.text = game.gameDate;
    cell.gameTitle.text = game.gameTitle;
    cell.highPriceLabel.text = game.highPrice;
    cell.lowPriceLabel.text = game.lowPrice;
    cell.numTicketsLabel.text = game.numTickets;
    [self setupGameImage: game.gameTitle forCell: cell];

    if([indexPath row] % 2 == 0) {
        
        cell.backgroundColor = [UIColor colorWithRed:243.0f/255.0f
                                               green:248.0f/255.0f
                                                blue:38.0f/255.0f
                                               alpha:1.0];
    } else if ([indexPath row] % 2 == 1) {
        cell.backgroundColor = [UIColor colorWithRed:239.0f/255.0f
                                               green:241.0f/255.0f
                                                blue:244.0f/255.0f
                                               alpha:1.0];
    }
    
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
        return 240; // Expanded height
    }
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
        vc.game_id = @1; 
    }
}

-(void)buyOrSellSegue:(BOOL)buyOrSell{
    if(buyOrSell) {
        [self performSegueWithIdentifier:@"ticketSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"ticketSegue" sender:self];
    }
}

-(void)setupGameImage: (NSString *)gameString forCell: (TicketTableCell *)cell{
    if([gameString isEqualToString:@"Michigan State"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"msuLogo"]]; 
    } else if([gameString isEqualToString:@"Northwestern"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"nwLogo"]];
    } else if([gameString isEqualToString:@"Ohio State"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"osuLogo"]]; 
    } else if([gameString isEqualToString:@"Utah"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"utahLogo"]]; 
    } else if([gameString isEqualToString:@"UNLV"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"unlvLogo"]]; 
    } else if([gameString isEqualToString:@"BYU"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"byuLogo"]];
    } else if([gameString isEqualToString:@"Maryland"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"marylandLogo"]];
    } else if([gameString isEqualToString:@"Minnesota"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"minnesotaLogo"]];
    } else if([gameString isEqualToString:@"Rutgers"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"rutgersLogo"]];
    } else if([gameString isEqualToString:@"Indiana"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"indianaLogo"]];
    } else if([gameString isEqualToString:@"Florida"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"floridaLogo"]];
    } else if([gameString isEqualToString:@"Penn State"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"psuLogo"]];
    } else if([gameString isEqualToString:@"Oregon State"]) {
        [cell.gameImage setImage:[UIImage imageNamed:@"oregonstateLogo"]];
    }
    return; 
}

@end
