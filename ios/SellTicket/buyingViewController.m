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
#import "postTicketViewController.h"
#import "global.h"


@implementation buyingViewController {
    NSMutableDictionary *rowToGameID;
    UIActivityIndicatorView *spinner;
}

-(void)viewDidLoad {
    [self setupEverything];
    //Maybe I don't have to do anything in here? Just do in ViewDidAppear?
    //   [self setup];
    spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center=CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.5);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    UIImage *image = [UIImage imageNamed:@"namebarLogo"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:239.0f/255.0f
                                                                           green:241.0f/255.0f
                                                                            blue:244.0f/255.0f
                                                                           alpha:1.0f];
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem *systemItem1 = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"profile"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(profileSegue)];
    self.navigationItem.rightBarButtonItem = systemItem1;
    rowToGameID = [[NSMutableDictionary alloc]init];
}

-(void)viewDidAppear:(BOOL)animated {
    [self setup];
    [self.tableView reloadData];
}

-(void) setup {
    [self setupGames];
}

-(void) setupTickets: (NSNumber *)game_id {
    //Now load in all the tickets that are currently in the server. Might not be the smart way
    //Default is setting the ticket access to 1 for Michigan
    NSString *ticketServerAddress
        = [NSString stringWithFormat: @"http://ec2-52-24-188-41.us-west-2.compute.amazonaws.com:80/api/games/%@/tickets", game_id];
    
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
    
    for(id game in gameOfArrays) {
        gameClass *newGame = [[gameClass alloc]init];
        
        NSNumber *game_id = [game objectForKey:@"game_id"];
        NSString *away_id = [game objectForKey:@"away_team_id"];
        
        [self setupTickets: game_id];
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
        
        newGame.game_id = game_id;
        newGame.gameTitle = [schoolDictionary objectForKey:away_id];
        newGame.gameDate = [game objectForKey:@"date"];
        
        //Add the opponent of the gameID also
        [gameIDToSchool setObject:newGame.gameTitle forKey:game_id];
        
        [self.games addObject:newGame];
    }
    [spinner stopAnimating];
    [self.tableView setHidden:NO];
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
    cell.gameImage.image = [self setupGameImage:game.gameTitle];
    
    [rowToGameID setObject:game.game_id forKey:indexPath];

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
    if([[segue identifier] isEqualToString:@"buySegue"]){
        ticketListingsViewController *vc = [segue destinationViewController];
        NSInteger selectedRow = self.selectedIndex.row;
        gameClass *game = [self.games objectAtIndex:selectedRow];
        vc.gameString = game.gameTitle;
        vc.dateString = game.gameDate;
        vc.locationString = @"Michigan Stadium";
        vc.image = [self setupGameImage:vc.gameString];
        vc.game_id = [rowToGameID objectForKey:self.selectedIndex];
        vc.highestPriceString = game.highPrice;
        vc.lowestPriceString = game.lowPrice;
        vc.numTicketsString = game.numTickets;
    } else if([[segue identifier] isEqualToString:@"sellSegue"]) {
        postTicketViewController *vc = [segue destinationViewController];
        NSInteger selectedRow = self.selectedIndex.row;
        gameClass *game = [self.games objectAtIndex:selectedRow];
        vc.gameString = game.gameTitle;
        vc.dateString = game.gameDate;
        vc.locationString = @"Michigan Stadium";
        vc.image = [self setupGameImage:vc.gameString];
        vc.game_id = [rowToGameID objectForKey:self.selectedIndex];
        vc.highestPriceString = game.highPrice;
        vc.lowestPriceString = game.lowPrice;
        vc.numTicketsString = game.numTickets;
    }
}

-(void)buyOrSellSegue:(BOOL)buyOrSell{
    if(buyOrSell) {
        [self performSegueWithIdentifier:@"sellSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"buySegue" sender:self];
    }
}

-(UIImage *)setupGameImage: (NSString *)gameString{
    if([gameString isEqualToString:@"Michigan State"]) {
        return [UIImage imageNamed:@"msuLogo"];
    } else if([gameString isEqualToString:@"Northwestern"]) {
        return [UIImage imageNamed:@"nwLogo"];
    } else if([gameString isEqualToString:@"Ohio State"]) {
        return [UIImage imageNamed:@"osuLogo"];
    } else if([gameString isEqualToString:@"Utah"]) {
        return [UIImage imageNamed:@"utahLogo"];
    } else if([gameString isEqualToString:@"UNLV"]) {
        return [UIImage imageNamed:@"unlvLogo"];
    } else if([gameString isEqualToString:@"BYU"]) {
        return [UIImage imageNamed:@"byuLogo"];
    } else if([gameString isEqualToString:@"Maryland"]) {
        return [UIImage imageNamed:@"marylandLogo"];
    } else if([gameString isEqualToString:@"Minnesota"]) {
        return [UIImage imageNamed:@"minnesotaLogo"];
    } else if([gameString isEqualToString:@"Rutgers"]) {
        return [UIImage imageNamed:@"rutgersLogo"];
    } else if([gameString isEqualToString:@"Indiana"]) {
        return [UIImage imageNamed:@"indianaLogo"];
    } else if([gameString isEqualToString:@"Florida"]) {
        return [UIImage imageNamed:@"floridaLogo"];
    } else if([gameString isEqualToString:@"Penn State"]) {
        return [UIImage imageNamed:@"psuLogo"];
    } else if([gameString isEqualToString:@"Oregon State"]) {
        return [UIImage imageNamed:@"oregonstateLogo"];
    }
    return [UIImage imageNamed:@"Michigan State"];
}

-(void)profileSegue{
    [self performSegueWithIdentifier:@"profileSegue" sender:self]; 
}

-(void) setupEverything {
    //Whenever the application loads, make a request to acquire a list of all the schools
    //Get the object as a JSON Dictionary
    NSString *serverAddress
    = @"http://ec2-52-24-188-41.us-west-2.compute.amazonaws.com:80/api/schools";
    NSMutableURLRequest *request
    =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverAddress]
                             cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                         timeoutInterval: 10];
    
    [request setHTTPMethod: @"GET"];
    
    // Set auth header
    NSString * bearerHeaderStr = @"Bearer ";
    [request setValue:[bearerHeaderStr stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSError *requestError = nil;
    NSURLResponse *urlResponse = nil;
    NSData *response1
    = [NSURLConnection sendSynchronousRequest:request
                            returningResponse:&urlResponse
                                        error:&requestError];
    
    NSDictionary *schools
    = [NSJSONSerialization JSONObjectWithData:response1
                                      options:kNilOptions
                                        error:&requestError];
    
    
    //Iterate through all of the school names and put them into
    //the schoolDictionary global variable.
    for(NSDictionary *school in schools) {
        NSNumber * school_id = [school objectForKey:@"school_id"];
        NSString * school_name = [school objectForKey:@"name"];
        [schoolDictionary setObject:school_name forKey:school_id];
        
        //For every school, we also want to load in a list of all the games
        //that correspond to school
        serverAddress
        = [NSString stringWithFormat:@"http://ec2-52-24-188-41.us-west-2.compute.amazonaws.com/api/schools/%@/games", school_id];
        
        request = [NSMutableURLRequest requestWithURL:[NSURL
                                                       URLWithString:serverAddress]
                                          cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                      timeoutInterval:10];
        [request setHTTPMethod:@"GET"];
        
        // Set auth header
        [request setValue:[bearerHeaderStr stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
        
        requestError = nil;
        urlResponse = nil;
        
        response1
        = [NSURLConnection sendSynchronousRequest:request
                                returningResponse:&urlResponse
                                            error:&requestError];
        
        id jsonDictionary2 = [[NSMutableDictionary alloc]init];
        jsonDictionary2
        = [NSJSONSerialization JSONObjectWithData:response1
                                          options:kNilOptions
                                            error:&requestError];
        
        //Set a list of games for every school
        [gameDictionary setObject:jsonDictionary2 forKey:school_id];
    }

}
@end
