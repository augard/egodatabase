//
//  EGODatabaseRequestBlock.m
//
//  Created by Constantine Mureev on 9/1/11.
//

#import "EGODatabaseRequestBlock.h"

@interface OperationCallback ()
@property (readwrite, nonatomic, copy) id successBlock;
@property (readwrite, nonatomic, copy) id errorBlock;
@end

@implementation OperationCallback
@synthesize successBlock = _successBlock;
@synthesize errorBlock = _errorBlock;

+ (id)callbackWithSuccess:(id)success error:(id)error {
	id callback = [[[self alloc] init] autorelease];
	[callback setSuccessBlock:success];
	[callback setErrorBlock:error];
	
	return callback;
}

- (id)init {
	if ([self class] == [OperationCallback class]) {
		[NSException raise:NSInternalInconsistencyException format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
	}
	
	return [super init];
}

- (void)dealloc {
	[_successBlock release];
	[_errorBlock release];
	[super dealloc];
}

@end

@implementation EGODatabaseRequestBlock
@dynamic successBlock, errorBlock;
@end
