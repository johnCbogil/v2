//
//  RepsManager.h
//  Voices
//
//  Created by John Bogil on 11/13/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface RepsManager : NSObject

+(RepsManager *) sharedInstance;
- (NSArray *)fetchRepsForIndex:(NSInteger)index;
- (void)createFederalRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)getRepContactForms;
- (void)createStateRepresentativesFromLocation:(CLLocation *)location WithCompletion:(void (^)(void))successBlock onError:(void (^)(NSError *))errorBlock;
- (void)createNYCRepsFromLocation:(CLLocation *)location;

@property (strong, nonatomic) NSArray *nycDistricts;
@property (strong, nonatomic) NSDictionary *repsContactForms;
@property (strong, nonatomic) NSMutableArray *localReps;
@property BOOL isLocalRepsAvailable;

@end
