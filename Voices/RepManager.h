//
//  RepManager.h
//  Voices
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
@property (strong, nonatomic) NSArray *listOfFederalRepresentatives;
@property (strong, nonatomic) NSArray *listOfStateRepresentatives;
@property (strong, nonatomic) NSMutableArray *listOfNYCRepresentatives;
@property (strong, nonatomic) NSString *currentCouncilDistrict;
@property (strong, nonatomic) NSArray *nycDistricts;
- (void)createFederalRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                                         onError:(void(^)(NSError *error))errorBlock;
- (void)createStateRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                                       onError:(void(^)(NSError *error))errorBlock;
- (void)createNYCRepsFromLocation:(CLLocation*)location;
- (NSArray *)fetchRepsFromCache:(NSString *)representativeType;
- (NSArray *)createRepsForIndex:(NSInteger)index;
- (void)startUpdatingLocation;

@end