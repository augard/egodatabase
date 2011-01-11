#import "EGODatabase.h"
#import "EDODatabaseAdditions.h"
#import "EGODatabaseRow.h"

@implementation EGODatabase (EGODatabaseAdditions)

#define RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(type, sel)             \
va_list args;                                                        \
va_start(args, query);                                               \
EGODatabaseResult *resultSet =[self executeQuery:query ];   \
va_end(args);                                                        \
if (resultSet.count ==0) { return (type)0; }                         \
type ret = nil;														\
for(EGODatabaseRow *row in resultSet) {								\
		ret = [row sel:0];										\
}																	\
return ret;															\




- (NSString*)stringForQuery:(NSString*)query, ...; {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(NSString *, stringForColumnIndex);
}

- (int)intForQuery:(NSString*)query, ...; {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(int, intForColumnIndex);
}

- (long)longForQuery:(NSString*)query, ...; {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(long, longForColumnIndex);
}

- (BOOL)boolForQuery:(NSString*)query, ...; {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(BOOL, boolForColumnIndex);
}

/*- (double)doubleForQuery:(NSString*)query, ...; {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(double, doubleForColumnIndex);
}*/

- (NSData*)dataForQuery:(NSString*)query, ...; {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(NSData *, dataForColumnIndex);
}

- (NSDate*)dateForQuery:(NSString*)query, ...; {
    RETURN_RESULT_FOR_QUERY_WITH_SELECTOR(NSDate *, dateForColumnIndex);
}


//check if table exist in database (patch from OZLB)
- (BOOL)tableExists:(NSString*)tableName {
    
    BOOL returnBool;
    //lower case table name
    tableName = [tableName lowercaseString];
    //search in sqlite_master table if table exists
    EGODatabaseResult *result = [self executeQueryWithParameters:@"select [sql] from sqlite_master where [type] = 'table' and lower(name) = ?", tableName,nil];
    //if at least one row exists, table exists
    for(EGODatabaseRow *row in result) {
		return YES;
	}
    return NO;
}

//get table with list of tables: result colums: type[STRING], name[STRING],tbl_name[STRING],rootpage[INTEGER],sql[STRING]
//check if table exist in database  (patch from OZLB)
- (EGODatabaseResult*)getSchema {
    
    //result colums: type[STRING], name[STRING],tbl_name[STRING],rootpage[INTEGER],sql[STRING]
    EGODatabaseResult *result  = [self executeQuery:@"SELECT type, name, tbl_name, rootpage, sql FROM (SELECT * FROM sqlite_master UNION ALL SELECT * FROM sqlite_temp_master) WHERE type != 'meta' AND name NOT LIKE 'sqlite_%' ORDER BY tbl_name, type DESC, name"];
    
    return result;
}

//get table schema: result colums: cid[INTEGER], name,type [STRING], notnull[INTEGER], dflt_value[],pk[INTEGER]
- (EGODatabaseResult*)getTableSchema:(NSString*)tableName {
    
    //result colums: cid[INTEGER], name,type [STRING], notnull[INTEGER], dflt_value[],pk[INTEGER]
    EGODatabaseResult *result = [self executeQueryWithParameters:[NSString stringWithFormat: @"PRAGMA table_info(%@)", tableName],nil];
	for(EGODatabaseRow *row in result) {
	/* NSLog(@"cid: %d",[row intForColumn:@"cid"]);
	 NSLog(@"name: %@",[row stringForColumn:@"name"]);
	 NSLog(@"type: %@",[row stringForColumn:@"type"]);
	 NSLog(@"notnull: %d",[row intForColumn:@"notnull"]);
	 NSLog(@"dflt_value: %d",[row intForColumn:@"dflt_value"]);
	 NSLog(@"pk: %d",[row intForColumn:@"pk"]);	*/	
	}
    return result;
}


//check if column exist in table
- (BOOL)columnExists:(NSString*)tableName columnName:(NSString*)columnName {
    
    BOOL returnBool = NO;
    //lower case table name
    tableName = [tableName lowercaseString];
    //lower case column name
    columnName = [columnName lowercaseString];
    //get table schema
    EGODatabaseResult *result = [self getTableSchema: tableName];
    //check if column is present in table schema
    for(EGODatabaseRow *row in result) {
        if ([[[row stringForColumn:@"name"] lowercaseString] isEqualToString: columnName]) {
            returnBool = YES;
            break;
        }
    }
    
    return returnBool;
}

@end
