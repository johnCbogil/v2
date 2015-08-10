//
//  RepManager.h
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Congressperson.h"
#import "UIImageView+AFNetworking.h"
#import <CoreLocation/CoreLocation.h>

@interface RepManager : NSObject
+(RepManager *) sharedInstance;
@property (strong, nonatomic) NSArray *listOfCongressmen;
@property (strong, nonatomic) NSArray *listofStateLegislators;
- (void)createCongressmenFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                              onError:(void(^)(NSError *error))errorBlock;
- (void)createStateLegislators:(void(^)(void))successBlock
                       onError:(void(^)(NSError *error))errorBlock;
- (void)assignInfluenceExplorerID:(Congressperson*)congressperson withCompletion:(void(^)(void))successBlock
                          onError:(void(^)(NSError *error))errorBlock;
- (void)assignTopContributors:(Congressperson*)congressperson withCompletion:(void(^)(void))successBlock
                      onError:(void(^)(NSError *error))errorBlock;
- (void)assignTopIndustries:(Congressperson*)congressperson withCompletion:(void(^)(void))successBlock
                    onError:(void(^)(NSError *error))errorBlock;
- (void)createCongressmenFromQuery:(NSString*)query WithCompletion:(void(^)(void))successBlock
                           onError:(void(^)(NSError *error))errorBlock;
@end
