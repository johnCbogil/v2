//
//  NetworkManager.h
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject
+(NetworkManager *) sharedInstance;
- (void)determineCongressmenWithCompletion:(void(^)(NSArray *results))successBlock
                                   onError:(void(^)(NSError *error))errorBlock;
@end
