# Tikkit App Server

## Setup

1. Configure port-forwarding    
    `$ sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to $APP_SERVER_PORT`
2. Navigate to the server directory  
    `$ cd $TIKKIT_DIR/server`
3. Install required modules  
    `$ npm install`
4. Create database tables  
    `$ sqlite3 db/app-data.db < db/scripts/create_tables.sql`
5. Launch server  
    `$ node server.js`

## Configuration
The server config file can be found at `$TIKKIT_DIR/server/config.json`.  

**Name** | **Type** | **Description**
--- | --- | ---
`port` | integer | **Required.** The port the server listens on.
`logDir` | string | **Required.** The path to the server's log directory.
`dbFile` | string | **Required.** The path to the server's SQLite3 database file.
`passwordSaltLength` | integer | **Required.** The length of the password salt, in bytes.
`secret` | string | **Required.** The server secret, used to generate access tokens.
`tokenTtl` | integer | **Required.** The access token time-to-live, in days.

## API
*Version 0.0.8*

### **Unprotected**
The following API endpoints do not require any authorization.

### Create
Create a new user.  
`POST /create`
#### Input
**Name** | **Type** | **Description**
--- | --- | ---
`username` | string | **Required.** The name of the user. Must end with *@umich.edu*.
`password` | string | **Required.** The password associated with the username. Must be at least 8 characters long.
#### Example
```
POST /create HTTP/1.1
Host: localhost:8080
Content-Type: application/x-www-form-urlencoded

username=testuser%40umich.edu&password=password
```
#### Response
Status: *201 Created*  
```
{  
  "user_id": 1  
}
```

### Login
Log into an existing user account. Returns a bearer token to authorize the user to the API.  
`POST /login`
#### Input
**Name** | **Type** | **Description**
--- | --- | ---
`username` | string | **Required.** The name of the user.
`password` | string | **Required.** The password associated with the username.
#### Example
```
POST /login HTTP/1.1
Host: localhost:8080
Content-Type: application/x-www-form-urlencoded

username=testuser%40umich.edu&password=password
```
#### Response
Status: *200 OK*
```
{
  "user_id": 1,
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjI5LCJleHAiOjE0NTIwMzM3NTI5MDF9.qqFP256KNORdX9T8qwQNscYroeIiDFA0zkshCaDHMPU",
  "expires": 1452033752901
}
```

### **Protected**
The following API endpoints require a bearer token passed via the "Authorization" header.

### Get user
`GET /api/users/:user_id`
#### Example
```
GET /api/users/1 HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjI5LCJleHAiOjE0NTIwMzM3NTI5MDF9.qqFP256KNORdX9T8qwQNscYroeIiDFA0zkshCaDHMPU
```
#### Response
Status: *200 OK*
```
{
  "user_id": 1,
  "username": "testuser@umich.edu"
}
```

### List tickets for user
List all of the tickets for sale by a given user.
`GET /api/users/:user_id/tickets`
#### Example
```
GET /api/users/1/tickets HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjI5LCJleHAiOjE0NTIwMzM3NTI5MDF9.qqFP256KNORdX9T8qwQNscYroeIiDFA0zkshCaDHMPU
```
#### Response
Status: *200 OK*
```
[
  {
    "ticket_id": 1,
    "game_id": 1,
    "seller_id": 1,
    "section": 32,
    "row": 1,
    "seat": 1,
    "price": 4500,
    "sold": 0
  },
  {
    "ticket_id": 2,
    "game_id": 1,
    "seller_id": 1,
    "section": 32,
    "row": 1,
    "seat": 2,
    "price": 5000,
    "sold": 0
  }
]
```

### List schools
List all of the schools.  
`GET /api/schools`
#### Example
```
GET /api/schools HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjI5LCJleHAiOjE0NTIwMzM3NTI5MDF9.qqFP256KNORdX9T8qwQNscYroeIiDFA0zkshCaDHMPU
```
#### Response
Status: *200 OK*
```
[
  {
    "school_id": 1,
    "name": "Michigan"
  },
  {
    "school_id": 2,
    "name": "Ohio State"
  },
  {
    "school_id": 3,
    "name": "Stanford"
  },
  {
    "school_id": 4,
    "name": "Cal"
  }
]
```

### Get school
`GET /api/schools/:school_id`
#### Example
```
GET /api/schools/1 HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjI5LCJleHAiOjE0NTIwMzM3NTI5MDF9.qqFP256KNORdX9T8qwQNscYroeIiDFA0zkshCaDHMPU
```
#### Response
Status: *200 OK*
```
{
  "school_id": 1,
  "name": "Michigan"
}
```

### List games for school
List all of the games associated with a given school.  
`GET /api/schools/:school_id/games`
#### Example
```
GET /api/schools/1/games HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjI5LCJleHAiOjE0NTIwMzM3NTI5MDF9.qqFP256KNORdX9T8qwQNscYroeIiDFA0zkshCaDHMPU
```
#### Response
Status: *200 OK*
```
[
  {
    "game_id": 1,
    "home_team_id": 1,
    "away_team_id": 2,
    "date": "2015-01-01 00:00:00.000"
  },
  {
    "game_id": 3,
    "home_team_id": 1,
    "away_team_id": 3,
    "date": "2015-01-01 00:00:00.000"
  }
]
```

### Get game
`GET /api/games/:game_id`
#### Example
```
GET /api/games/1 HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjI5LCJleHAiOjE0NTIwMzM3NTI5MDF9.qqFP256KNORdX9T8qwQNscYroeIiDFA0zkshCaDHMPU
```
#### Response
Status: *200 OK*
```
{
  "game_id": 1,
  "home_team_id": 1,
  "away_team_id": 2,
  "date": "2015-01-01 00:00:00.000"
}
```

### List tickets for game
List all of the tickets associated with a given game.  
`GET /api/games/:game_id/tickets`
#### Example
```
GET /api/games/1/tickets HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjI5LCJleHAiOjE0NTIwMzM3NTI5MDF9.qqFP256KNORdX9T8qwQNscYroeIiDFA0zkshCaDHMPU
```
#### Response
```
[
  {
    "ticket_id": 1,
    "game_id": 1,
    "seller_id": 1,
    "section": 32,
    "row": 1,
    "seat": 1,
    "price": 4500,
    "sold": 0
  },
  {
    "ticket_id": 2,
    "game_id": 1,
    "seller_id": 1,
    "section": 32,
    "row": 1,
    "seat": 2,
    "price": 5000,
    "sold": 0
  },
  {
    "ticket_id": 3,
    "game_id": 1,
    "seller_id": 2,
    "section": 32,
    "row": 35,
    "seat": 26,
    "price": 4000,
    "sold": 1
  }
]
```

### Create ticket
Create a new ticket for the given game.  
`POST /api/games/:game_id/tickets/create`
#### Input
**Name** | **Type** | **Description**
--- | --- | ---
`section` | integer | **Required.** The section the ticket is in. Must be a positive integer.
`row` | integer | **Required.** The row the ticket is in. Must be a positive integer.
`seat` | integer | **Required.** The seat the ticket is in. Must be a positive integer.
`price` | integer | **Required.** The price of the ticket, in cents. Must be a non-negative integer.
#### Example
```
POST /api/games/1/tickets/create HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjI5LCJleHAiOjE0NTIwMzM3NTI5MDF9.qqFP256KNORdX9T8qwQNscYroeIiDFA0zkshCaDHMPU
Content-Type: application/x-www-form-urlencoded

section=32&row=1&seat=1&price=5000
```
#### Response
Status: *201 Created*
```
{
  "ticket_id": 1
}
```

### Get ticket
`GET /api/tickets/:ticket_id`
#### Example
```
GET /api/tickets/1 HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjI5LCJleHAiOjE0NTIwMzM3NTI5MDF9.qqFP256KNORdX9T8qwQNscYroeIiDFA0zkshCaDHMPU
```
#### Response
Status: *200 OK*
```
{
  "ticket_id": 1,
  "game_id": 1,
  "seller_id": 1,
  "section": 32,
  "row": 1,
  "seat": 1,
  "price": 5000,
  "sold": 0
}
```

### Update ticket
Update the price and sold status for the given ticket. Only available to the user that created the ticket.  
`POST /api/tickets/:ticket_id/update`
#### Input
**Name** | **Type** | **Description**
--- | --- | ---
`price` | integer | Optional. The price of the ticket, in cents. Must be a non-negative integer.
`sold` | boolean | Optional. Set to 1 if the ticket has been sold, 0 otherwise.
#### Example
```
POST /api/tickets/1/update HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjI5LCJleHAiOjE0NTIwMzM3NTI5MDF9.qqFP256KNORdX9T8qwQNscYroeIiDFA0zkshCaDHMPU
Content-Type: application/x-www-form-urlencoded

price=4000&sold=1
```
#### Response
Status: *204 No Content*

### Destroy ticket
Delete the given ticket. Only available to the user that created the ticket.  
`POST /api/tickets/:ticket_id/destroy`
#### Example
```
POST /api/tickets/1/destroy HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjI5LCJleHAiOjE0NTIwMzM3NTI5MDF9.qqFP256KNORdX9T8qwQNscYroeIiDFA0zkshCaDHMPU
Content-Type: application/x-www-form-urlencoded
```
#### Response
Status: *204 No Content*

