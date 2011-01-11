//  Credits to August Mueller 
//  Flying Meat Inc..
// 
#import <Foundation/Foundation.h>
@interface EGODatabase (EGODatabaseAdditions)


- (int)intForQuery:(NSString*)objs, ...;
- (long)longForQuery:(NSString*)objs, ...; 
- (BOOL)boolForQuery:(NSString*)objs, ...;
//- (double)doubleForQuery:(NSString*)objs, ...;
- (NSString*)stringForQuery:(NSString*)objs, ...; 
- (NSData*)dataForQuery:(NSString*)objs, ...;
- (NSDate*)dateForQuery:(NSString*)objs, ...;



- (BOOL)tableExists:(NSString*)tableName;
- (EGODatabaseResult*)getSchema;
- (EGODatabaseResult*)getTableSchema:(NSString*)tableName;
- (BOOL)columnExists:(NSString*)tableName columnName:(NSString*)columnName;

@end
