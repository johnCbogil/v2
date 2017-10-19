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
- (void)fetchRepsForAddress:(NSString *)address;
- (void)createFederalRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                                         onError:(void(^)(NSError *error))errorBlock;
-(void)createStateRepresentativesFromLocation:(CLLocation *)location WithCompletion:(void (^)(void))successBlock onError:(void (^)(NSError *))errorBlock;
- (void)createLocalRepsFromLocation:(CLLocation *)location;
- (NSString *)getContactFormForBioGuide:(NSString *)bioguide;
@property (strong, nonatomic) NSArray *localDistricts;
@property (strong, nonatomic) NSArray *fedReps;
@property (strong, nonatomic) NSArray *stateReps;
@property (strong, nonatomic) NSMutableArray *localReps;
@property BOOL isLocalRepsAvailable;

@end
