//
//  EGODatabaseRequest.m
//  EGODatabase
//
//  Created by Shaun Harrison on 10/18/09.
//  Copyright (c) 2009 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGODatabaseRequest.h"
#import "EGODatabase.h"

@interface EGODatabaseRequest (Private)
- (void)didSucceedWithResult:(EGODatabaseResult*)result;
- (void)didFailWithError:(NSError*)error;
@end


@implementation EGODatabaseRequest
@synthesize requestKind, database, delegate, block, tag;

static dispatch_queue_t get_sqlite_io_queue() {
    static dispatch_queue_t _diskIOQueue;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_diskIOQueue = dispatch_queue_create("sqlite.io", NULL);
	});
	return _diskIOQueue;
}


- (id)initWithQuery:(NSString*)aQuery {
	return [self initWithQuery:aQuery parameters:nil];
}

- (id)initWithQuery:(NSString*)aQuery parameters:(NSArray*)someParameters {
	if((self = [super init])) {
		query = aQuery;
		parameters = someParameters;
		requestKind = EGODatabaseSelectRequest;
	}
	
	return self;
}
- (void)fire {
	if(self.delegate == nil && self.block == nil){
		EGODBDebugLog(@"[EGODatabase] FATAL: please specify the callback delegate or block");
		return;
	}
	if(self.database == nil){
		EGODBDebugLog(@"[EGODatabase] FATAL: please specify the database");
		return;
	}

	[self main];
}

- (void)dispatchAsync {    
    dispatch_async(get_sqlite_io_queue(), ^{        
        [self main];
    });
}

- (void)main {
	@autoreleasepool {
		if(self.requestKind == EGODatabaseUpdateRequest) {
			BOOL result = [self.database executeUpdate:query parameters:parameters];
			
			if(result) {
				[self didSucceedWithResult:nil];
			} else {
				NSString* errorMessage = [self.database lastErrorMessage];
				NSDictionary* userInfo = nil;
				
				if(errorMessage) {
					userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:@"message"];
				}
				
				NSError* error = [NSError errorWithDomain:@"com.egodatabase.update"
													 code:[self.database lastErrorCode]
												 userInfo:userInfo];
				
				[self didFailWithError:error];
			}
		} else {
			EGODatabaseResult* result = [self.database executeQuery:query parameters:parameters];
			
			if(result.errorCode == 0) {
				[self didSucceedWithResult:result];
			} else {
				NSDictionary* userInfo = nil;
				
				if(result.errorMessage) {
					userInfo = [NSDictionary dictionaryWithObject:result.errorMessage forKey:@"message"];
				}
				
				NSError* error = [NSError errorWithDomain:@"com.egodatabase.select"
													 code:result.errorCode
												 userInfo:userInfo];
				
				[self didFailWithError:error];
			}
		}
	}
}

- (void)didSucceedWithResult:(EGODatabaseResult*)result {
    if (self.block.successBlock) {
        self.block.successBlock(result);
    }
    
	if(delegate && [delegate respondsToSelector:@selector(requestDidSucceed:withResult:)]) {
		[delegate requestDidSucceed:self withResult:result];
	}
}

- (void)didFailWithError:(NSError*)error {
    if (self.block.errorBlock) {
        self.block.errorBlock(error);
    }
    
	if(delegate && [delegate respondsToSelector:@selector(requestDidFail:withError:)]) {
		[delegate requestDidFail:self withError:error];
	}
}

@end
