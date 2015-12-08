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
        = @"http://ec2-52-24-188-41.us-west-2.compute.amazonaws.com:80/api/lists/games/1/tickets";
    
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
            newGame.lowPrice = [NSString stringWithFormat: @"$%li", lowestValue];
            newGame.highPrice = [NSString stringWithFormat:@"$%i", highestValue];
            newGame.numTickets = [NSString stringWithFormat:@"%lu listed", (unsigned long)[tickets count]];
        } else {
            newGame.lowPrice = @"$0";
            newGame.highPrice = @"$0";
            newGame.numTickets = @"0 listed";
        }
        
        newGame.gameTitle
        = [NSString stringWithFormat:@"Michigan vs. %@", [schoolDictionary objectForKey:away_id]];
        newGame.gameDate
        = [NSString stringWithFormat:@"%@", [game objectForKey:@"date"]];
        
        [self.games addObject:newGame];
    }
}
//    for(id game in gameDictionary) {
//        //Get opponenets name
//        id game_object = [gameDictionary objectForKey:game];
//
//        //Work on conversion later
//        NSNumber *homeGameID = [game_object objectForKey:@"home_team_id"];
//
//        //This check is just so we're doing for Michigan Games right now
//        if([homeGameID isEqual: @1]) {
//            gameClass *newGame = [[gameClass alloc]init];
//            NSString *away_id = [game_object objectForKey:@"away_team_id"];
//            newGame.gameTitle = [NSString stringWithFormat:@"Michigan vs. %@", [schoolDictionary objectForKey: away_id]];
//            newGame.gameDate = [NSString stringWithFormat:@"%@", [game_object objectForKey:@"date"]];
//            
//            
//            if([ticketDictionary objectForKey:homeGameID]) {
//                NSMutableArray *tickets = [ticketDictionary objectForKey:homeGameID];
//                int highestValue = -1;
//                long int lowestValue = LONG_MAX;
//                for(ticketClass *ticket in tickets) {
//                    if((NSNumber *)[NSNull null] != ticket.price) {
//                        if([ticket.price intValue] > highestValue) {
//                            highestValue = [ticket.price intValue];
//                        }
//                        if([ticket.price intValue] < lowestValue) {
//                            lowestValue = [ticket.price intValue];
//                        }
//                    }
//                    NSLog(@"%@, %i, %li", ticket.price, highestValue, lowestValue);
//                }
//                newGame.lowPrice = [NSString stringWithFormat: @"$%li", lowestValue];
//                newGame.highPrice = [NSString stringWithFormat:@"$%i", highestValue];
//                newGame.numTickets = [NSString stringWithFormat:@"%lu listed", (unsigned long)[tickets count]];
//                newGame.game_id = [game_object objectForKey:@"game_id"]; 
//            } else {
//                newGame.lowPrice = @"$0";
//                newGame.highPrice = @"$0";
//                newGame.numTickets = @"0 listed";
//            }
//            [self.games addObject:newGame];
//        }
//    }

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
        vc.game_id = @1; 
    }
}


@end
