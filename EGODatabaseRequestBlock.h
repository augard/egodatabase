//
//  EGODatabaseRequestBlock.h
//
//  Created by Constantine Mureev on 9/1/11.
//

#import <Foundation/Foundation.h>
#import "EGODatabaseResult.h"

@protocol OperationCallback <NSObject>
+ (id)blockWithSuccess:(id)success error:(id)error;
@end

@interface OperationCallback : NSObject <OperationCallback> {
@private
	id _successBlock;
	id _errorBlock;
}

@end

typedef void (^RequestSuccessBlock)(EGODatabaseResult* result);
typedef void (^RequestErrorBlock)(NSError *error);

#pragma mark - EGODatabaseRequestBlock

@protocol EGODatabaseRequestBlock <NSObject>
@optional
+ (id)blockWithSuccess:(RequestSuccessBlock)success error:(RequestErrorBlock)error;
@end

@interface EGODatabaseRequestBlock : OperationCallback <EGODatabaseRequestBlock>
@property (readwrite, nonatomic, copy) RequestSuccessBlock successBlock;
@property (readwrite, nonatomic, copy) RequestErrorBlock errorBlock;
@end