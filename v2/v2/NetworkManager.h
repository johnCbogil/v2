//
//  NetworkManager.h
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import <CoreLocation/CoreLocation.h>

@interface NetworkManager : NSObject
+(NetworkManager *) sharedInstance;
- (void)getCongressmenFromLocation:(CLLocation*)location WithCompletion:(void(^)(NSDictionary *results))successBlock
onError:(void(^)(NSError *error))errorBlock;
- (void)getStateLegislatorsWithCompletion:(void(^)(NSDictionary *results))successBlock
                                        onError:(void(^)(NSError *error))errorBlock;
- (void)getCongressPhotos:(NSString*)bioguide withCompletion:(void(^)(UIImage *results))successBlock
                  onError:(void(^)(NSError *error))errorBlock;
- (void)getStatePhotos:(NSURL*)photoURL withCompletion:(void(^)(UIImage *results))successBlock
               onError:(void(^)(NSError *error))errorBlock;
- (void)idLookup:(NSString*)bioguide withCompletion:(void(^)(NSArray *results))successBlock
         onError:(void(^)(NSError *error))errorBlock;
- (void)getTopContributors:(NSString*)influenceExplorerID withCompletion:(void(^)(NSArray *results))successBlock
                   onError:(void(^)(NSError *error))errorBlock;
- (void)getTopIndustries:(NSString*)influenceExplorerID withCompletion:(void(^)(NSArray *results))successBlock
                 onError:(void(^)(NSError *error))errorBlock;
- (void)getStreetAddressFromSearchText:(NSString*)searchText withCompletion:(void(^)(NSArray *results))successBlock
                               onError:(void(^)(NSError *error))errorBlock;
@property (nonatomic, strong)AFHTTPRequestOperationManager *manager;

@end
