# About EGODatabase
EGODatabase is a thread-safe Objective SQLite wrapper created by enormego.  After extensively using FMDB in our applications, we saw a lot of room for improvements, the biggest was making it thread-safe.  EGODatabase uses some code from FMDB, but for the most part, it was completely reworked to use result sets and row objects.  A major difference between FMDB and EGODatabase is when selecting data, EGODatabase populates its EGODatabaseRow class with the data from SQLite, as opposed to retaining the SQLite results like FMDB does.

EGODatabase is tested to work with with iPhone OS and Mac OS X 10.5

# Classes
## EGODatabase
This is the class where you'll open your SQLite database file and execute queries through.

## EGODatabaseResult
This is the class returned by EGODatabase when running "executeQuery:".  It supports fast enumeration, and contains properties for the column names, column types, rows, and errors if there are any.

## EGODatabaseRow
Every object that EGODatabaseResult contains, is an EGODatabaseRow.  This is your raw data for each row.  You'll be able to return specific types based on different methods such as intForColumn: or dateForColumn:.  Check out the header files for a complete listing.

# Documentation
Check out each header file for a complete listing of each method.

# Example
	EGODatabase* database = [EGODatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"]];
	EGODatabaseResult* result = [database executeQuery:@"SELECT * FROM `posts` WHERE `post_user_id` = ?", [NSNumber numberWithInt:10]];
	for(EGODatabaseRow* row in result) {
		NSLog(@"Subject: %@", [row stringForColumn:@"post_subject"]);
		NSLog(@"Date: %@", [row dateForColumn:@"post_date"]);
		NSLog(@"Views: %d", [row intForColumn:@"post_views"]);
		NSLog(@"Message: %@", [row stringForColumn:@"post_message"]);
	}

# Migration from FMDB

    NSString *qry = [NSString stringWithFormat:@"SELECT * FROM customers"];
    FMResultSet *rs = [database executeQuery:qry];
	
    while([rs next]) {
        NSLog(@"%@",[rs stringForColumn:@"name"]);
     }
    [rs close];
	
     EGODatabaseResult *result = [database executeQuery:qry];
     for(EGODatabaseRow *row in result)
     {
        NNSLog(@"%@",[rs stringForColumn:@"name"]);
     }
	// don't need to close recordset
	
	
	FMResultSet *rs = [database executeQuery:@"SELECT * FROM customers WHERE name =? ",name,nil];
	->
	EGODatabaseResult *result = [database executeQueryWithParameters:@"SELECT * FROM customers WHERE name =? ",name,nil];

#EGODatabaseRequest - asynchronous requests to db 
	
	1) Implement the EGODatabaseRequestDelegate protocol
    Eg.   DataEnvironment : NSObject<EGODatabaseRequestDelegate> 

	2)	Add the requestDidSucceed /requestDidFail callback methods.
		
		
		-(void)requestDidSucceed:(EGODatabaseRequest*)request withResult:(EGODatabaseResult*)result
			if (request.tag == GETFRIENDS){
			     for(EGODatabaseRow *row in result)
			     {
			        NNSLog(@"%@",[rs stringForColumn:@"name"]);
			     }
			}
		}

		-(void)requestDidFail:(EGODatabaseRequest*)request withError:(NSError*)error{

			NSLog(@"WARNING requestDidFail");
		}

    3) 
	Create the requests / configure the delegate / database / add tags  
	finally issue the "fire" method.
	
	
	EGODatabaseRequest* request = [[EGODatabaseRequest alloc] initWithQuery:qry parameters:nil];
	request.delegate = self;
	request.database = appDelegate.database;
	request.tag = GETFRIENDS;
	request.requestKind = EGODatabaseSelectRequest;
	[request fire];
	[request release];



#transaction helper methods

BOOL bBegin = [database beginTransaction];
if(bBegin){
	[database executeQueryWithParameters:@"INSERT INTO customer (name) VALUES (?);","BobbyRay",nil];
	[database executeQueryWithParameters:@"INSERT INTO customer (name) VALUES (?);","BillyJean",nil];
	[database executeQueryWithParameters:@"INSERT INTO customer (name) VALUES (?);","MaryJane",nil];
	
}	
BOOL bBegin [database commit];

or if need be you can 
[database rollBack];
	
#tips
 1)    add this #define NUMBER(I)	[NSNumber numberWithInt:I]
	 [NSNumber numberWithInt:10] can be shortened to NUMBER(10)
	
 2)	add this to a common include file (substitute AppDelegate for the name of your app delegate)
	#define GET_DB()	(EGODatabase *)[(AppDelegate *)[[UIApplication sharedApplication] delegate] userdb]
	
	add this protocol to your AppDelegate in the header file above the interface.
	@protocol AppDelegate
		@property (nonatomic, retain) EGODatabase *userdb;
	@end
	
	now you can call GET_DB() from any file. 
	[GET_DB() executeQuery:@"SELECT * FROM CUSTOMERS"];
	
	
	
	
#Frequently Encountered Problems
  [EGODatabase] Invalid bind cound for number of arguments.
	You are likely passing in an int or nil values!!!! You must use NSString / NSNumber
	
	
	int i;
	for (i=0; i<[DATAENV.feelings count]; i++) {

		EGODatabaseResult *result = [self.appDelegate.userdb executeQueryWithParameters:@"SELECT tag_id FROM taggings WHERE  tag_id= ?",i,nil]; // FAIL
    }

	EGODatabaseResult *result = [self.appDelegate.userdb executeQueryWithParameters:@"SELECT tag_id FROM taggings WHERE  tag_id= ?",NUMBER(i),nil];



# Note
Remember to link libsqlite3.dylib to your project!


# Questions
Feel free to contact info@enormego.com if you need any help with EGODatabase.

# License
Copyright (c) 2009 enormego

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

