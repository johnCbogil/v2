//
//  RepManager.h
//  v3
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FederalRepresentative.h"
#import "UIImageView+AFNetworking.h"
#import <CoreLocation/CoreLocation.h>

@interface RepManager : NSObject

+(RepManager *) sharedInstance;
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) NSArray *listOfCongressmen;
@property (strong, nonatomic) NSMutableArray *listOfStateLegislators;
@property (strong, nonatomic) NSMutableArray *listOfNYCRepresentatives;
@property (strong, nonatomic) NSString *currentCouncilDistrict;
- (void)createCongressmenFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                              onError:(void(^)(NSError *error))errorBlock;
- (void)createStateLegislatorsFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                                   onError:(void(^)(NSError *error))errorBlock;
- (void)createNYCRepsFromLocation:(CLLocation*)location;

@end