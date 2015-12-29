//
//  profileViewController.m
//  SellTicket
//
//  Created by Eric Yu on 12/8/15.
//  Copyright © 2015 myne. All rights reserved.
//

#import "profileViewController.h"
#import "ProfileTableViewCell.h"
#import "global.h"

@implementation profileViewController {
}

-(void)viewDidLoad {
    [self setup];
}

-(void) setup {
    UIBarButtonItem *systemItem1 = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back-0"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = systemItem1;
    [self setupProfile];
    [self setupTickets];
   
}

-(void)setupProfile {
    
    NSString *userServerAddress
    = [NSString stringWithFormat: @"http://%@/api/users/%@", serverAddress, user_id];
    
    NSMutableURLRequest *request
    = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:userServerAddress]
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
    
    NSDictionary *userData
    = [NSJSONSerialization JSONObjectWithData:ticketResponse
                                      options:kNilOptions
                                        error:&requestError];

    NSString *emailAddress = [userData objectForKey:@"username"];
    self.name.text = @"Max Najork";
    self.email.text = [NSString stringWithFormat:@"Email: %@", emailAddress];
    self.phone.text = @"Phone: 248-248-2441"; 
    
}

-(void)setupTickets {
    self.tickets = [[NSMutableArray alloc]init];
    NSString *ticketServerAddress
    = [NSString stringWithFormat: @"http://%@/api/users/%@/tickets", serverAddress, user_id];
    
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
    
    NSArray *ticketsList
    = [NSJSONSerialization JSONObjectWithData:ticketResponse
                                      options:kNilOptions
                                        error:&requestError];
    if(ticketsList == NULL) {
        return;
    }
    for(NSDictionary *ticket in ticketsList) {
        [self.tickets addObject:ticket];
        NSLog(@"%@", ticket);
    }
    
    _ticketTable.dataSource = self;
    _ticketTable.delegate = self;
    [_ticketTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //count number of row from counting array hear category is An Array
    return [self.tickets count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"ProfileTableViewCell";
    
    ProfileTableViewCell *cell = (ProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProfileTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSDictionary *ticket = [self.tickets objectAtIndex:[indexPath row]];

    
    cell.price.text = [NSString stringWithFormat:@"$%@", [ticket objectForKey:@"price"]];
    cell.rowLabel.text = @"Row";
    cell.rowNumber.text = [NSString stringWithFormat:@"%@", [ticket objectForKey:@"row"]];
    cell.seatLabel.text = @"Seat";
    cell.seatNumber.text = [NSString stringWithFormat:@"%@", [ticket objectForKey:@"seat"]];
    cell.sectionNumber.text = [NSString stringWithFormat:@"%@", [ticket objectForKey:@"section"]];
    cell.sectionLabel.text = @"Section";
    cell.ticketImage.image = [UIImage imageNamed:@"buyTicket"];
    

    NSString *awayTeam = [gameIDToSchool objectForKey:[ticket objectForKey:@"game_id"]];
    cell.gameLabel.text = [NSString stringWithFormat:@"Michigan vs. %@", awayTeam];

    cell.clipsToBounds = YES;
    NSLog(@"GOT CALLED");
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
        return 154; // Expanded height
    }
    return 106;
}


@end
