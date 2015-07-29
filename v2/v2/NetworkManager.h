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
- (void)getCongressmenWithCompletion:(void(^)(NSArray *results))successBlock
                                   onError:(void(^)(NSError *error))errorBlock;
- (void)getStateLegislatorsWithCompletion:(void(^)(NSArray *results))successBlock
                                        onError:(void(^)(NSError *error))errorBlock;
- (void)getCongressPhotos:(NSString*)bioguide withCompletion:(void(^)(NSData *results))successBlock
                  onError:(void(^)(NSError *error))errorBlock;
- (void)getStatePhotos:(NSURL*)photoURL withCompletion:(void(^)(NSData *results))successBlock
               onError:(void(^)(NSError *error))errorBlock;
- (void)idLookup:(NSString*)bioguide withCompletion:(void(^)(NSData *results))successBlock
         onError:(void(^)(NSError *error))errorBlock;
- (void)getTopContributors:(NSString*)influenceExplorerID withCompletion:(void(^)(NSData *results))successBlock
                   onError:(void(^)(NSError *error))errorBlock;
- (void)getTopIndustries:(NSString*)influenceExplorerID withCompletion:(void(^)(NSData *results))successBlock
                 onError:(void(^)(NSError *error))errorBlock;
@end
