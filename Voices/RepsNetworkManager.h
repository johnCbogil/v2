//
//  NetworkManager.h
//  v3
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import <CoreLocation/CoreLocation.h>

@interface RepsNetworkManager : NSObject

+(RepsNetworkManager *) sharedInstance;
- (void)getFederalRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(NSDictionary *results))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)getStateRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(NSDictionary *results))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)getStreetAddressFromSearchText:(NSString*)searchText withCompletion:(void(^)(NSArray *results))successBlock
                               onError:(void(^)(NSError *error))errorBlock;
@property (nonatomic, strong)AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong)UIImage *missingRepresentativePhoto;

@end
