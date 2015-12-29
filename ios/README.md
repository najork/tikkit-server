#Tikkit iOS Application

##Overview
This is the iOS side of the Tikkit application built in EECS 441 Fall 2015. For fast development, storyboards were used to assist in creating the UI.

*For the future, the application should transition away from storyboard and into layout code instead. 

##View
2 main storyboards: 

1 is instantiated for user login and account creation. 
1 is used for the actual information that pertains to ticket selling and buying. 

To assist with the view, there are 3 custom made UITableViewCells. These are a part of the Custom Table View Cells Folder (folders are visible after you download the project). 

1. ListingsTableCell.xib 
	Used for every individual ticket. Linked with the ticketListingsViewController.
2. ProfileTableViewCell.xib
	Used to view individual tickets that a user has listed on the marketplace.Used in the profileViewController. 
3. TicketTableCell.xib
	Used to give the user an option to either buy or post a ticket. Used in the buyingViewController. 

##Controller
In total, there are 6 different view controllers: buyingViewController, loginViewController, newAccountViewController, ticketListingsViewController, postTicketViewController, and profileViewController. 

1. buyingViewController
	This is the main page that a user will see when he logs into the application. This is a part of the 2nd storyboard as mentioned above. Displays the available games that tickets can be posted to/bought from. 
2. loginViewController
	This is the first page the user will see when he/she opens the application. It is a part of the 1st storyboard as mentioned above. Simple login page with username and password input. 
3. newAccountViewController
	This is the 2nd view controller in the 1st storyboard. Allows a user to create a new account. 
4. ticketListingsViewController
	This is the view controller that holds onto all of the individual tickets that are associated with a game. A user navigates to this page through the buyingViewController. It is a part of the 2nd storyboard as mentioned above. 
5. postTicketViewController
	This is the view controller that allows a user to post a ticket to the database. A user navigates to this page through the buyingViewController. Also a part of the 2nd storyboard. 
6. profileViewController
	This view controller allows a user to see tickets that he/she has posted in the past. 

##Model
In the model, there are a few primary classes that are used. We keep track of a ticket class, a game class, and a class that handles server functions.

The ticket class allows us to add tickets to a globally allocated ticket dictionary. Additionally, we can figure out the highest and lowest prices for a specific game in this class. Every ticket has a section, row, seat, price, ticket_id, and seller_id attribute. 

The game class allows us to represent every game that is available. It has no separate methods, just attributes: gameTitle, lowPrice, highPrice, numTickets, gameDate, and game_id. 

The server functions help us reduce redundant code. Instead of having to create all the variables associated with the request every time we make a request, we utilize a function that only requires the server address and request type. 

##Images.xcassets
A variety of images that are referenced throughout the project can be easily accessed in here. 

##Additional Methods
We take a textFieldKeyboardShift library to help shift the keyboard when the user is typing (when the keyboard would otherwise cover the text field). 