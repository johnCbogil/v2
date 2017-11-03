//
//  RepsManager.m
//  Voices
//
//  Created by John Bogil on 11/13/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepsManager.h"
#import "RepsNetworkManager.h"
#import "FederalRepresentative.h"
#import "StateRepresentative.h"
#import "LocalRepresentative.h"
#import "LocationManager.h"

@interface RepsManager()


@property (strong, nonatomic) NSString *currentCouncilDistrict;
@property (strong, nonatomic) NSDictionary *federalRepContactFormURLs;
@end

@implementation RepsManager

+ (RepsManager *) sharedInstance {
    static RepsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        [[LocationManager sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
        self.isLocalRepsAvailable = YES;
        [self createFederalRepContactFormURLS];
    }
    return self;
}

- (NSArray *)fetchRepsForIndex:(NSInteger)index {
    if (index == 0) {
        return self.fedReps;
    }
    else if (index == 1) {
        return self.stateReps;
    }
    else if (index == 2) {
        return self.localReps;
    }
    else return @[];
}

- (void)fetchRepsForAddress:(NSString *)address {
    
    if (address.length) {
        [[LocationManager sharedInstance]getCoordinatesFromSearchText:address withCompletion:^(CLLocation *locationResults) {
            
            [[RepsManager sharedInstance]createFederalRepresentativesFromLocation:locationResults WithCompletion:^{
                NSLog(@"%@", locationResults);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
            
            [[RepsManager sharedInstance]createStateRepresentativesFromLocation:locationResults WithCompletion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
            
            [[RepsManager sharedInstance]createLocalRepsFromLocation:locationResults];
            
        } onError:^(NSError *googleMapsError) {
            NSLog(@"%@", [googleMapsError localizedDescription]);
        }];
    }
}

#pragma mark - Location Monitor

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        
        [self createFederalRepresentativesFromLocation:[LocationManager sharedInstance].currentLocation WithCompletion:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error){
            [error localizedDescription];
        }];
        
        [self createStateRepresentativesFromLocation:[LocationManager sharedInstance].currentLocation WithCompletion:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
        
        [self createLocalRepsFromLocation:[LocationManager sharedInstance].currentLocation];
    }
}

#pragma mark - Create Federal Representatives

- (void)createFederalRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                                         onError:(void(^)(NSError *error))errorBlock {
    
    [self createRepsFromNineDigitZip:@"110402003" WithCompletion:^{
        successBlock();
    } onError:^(NSError *error) {
        
    }];
    
//    [[RepsNetworkManager sharedInstance]getFederalRepsFromLocation:location WithCompletion:^(NSDictionary *results) {
//
//        NSMutableArray *listOfFederalRepresentatives = [[NSMutableArray alloc]init];
//        NSArray *officials = results[@"officials"];
//        NSArray *offices = results[@"offices"];
//
//        for (NSDictionary *office in offices) {
//
//            NSArray *officialIndices = office[@"officialIndices"];
//
//            for (NSNumber *officialIndex in officialIndices) {
//
//                NSMutableDictionary *official = [NSMutableDictionary dictionaryWithDictionary:officials[[officialIndex integerValue]]];
//                [official setObject:office forKey:@"office"];
//
//                FederalRepresentative *federalRep = [[FederalRepresentative alloc]initWithData:official];
//                [listOfFederalRepresentatives addObject:federalRep];
//                self.fedReps = listOfFederalRepresentatives;
//                successBlock();
//            }
//        }
//
//    } onError:^(NSError *error) {
//        errorBlock(error);
//    }];
}

- (void)createFederalRepContactFormURLS {
    
    [[RepsNetworkManager sharedInstance]getFederalContactFormURLSWithCompletion:^(NSDictionary *results) {
        self.federalRepContactFormURLs = results;
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}

- (NSString *)getContactFormForBioGuide:(NSString *)bioguide {
    return [self.federalRepContactFormURLs valueForKey:bioguide];
}

- (void)createRepsFromNineDigitZip:(NSString *)nineDigitZip WithCompletion:(void(^)(void))successBlock
                                         onError:(void(^)(NSError *error))errorBlock {
    
    NSMutableArray *listOfFederalRepresentatives = [[NSMutableArray alloc]init];

    [[RepsNetworkManager sharedInstance]getRepsFromNineDigitZip:nineDigitZip withCompletion:^(NSDictionary *results) {
        NSLog(@"%@", results);
        NSDictionary *candidateList = results[@"candidateList"];
        NSArray *candidates = candidateList[@"candidate"];
        for (NSDictionary *candidate in candidates) {
            NSString *candidateId = candidate[@"candidateId"];
            [[RepsNetworkManager sharedInstance]getRepFromCandidateId:candidateId withCompletion:^(NSDictionary *results) {
                if ([self isFederalRepresentative:candidate]) {
                    FederalRepresentative *federalRep = [[FederalRepresentative alloc]initWithData:candidate];
                    [listOfFederalRepresentatives addObject:federalRep];
                    self.fedReps = listOfFederalRepresentatives;
                }
            } onError:^(NSError *error) {
                
            }];
        }
    } onError:^(NSError *error) {
        [error localizedDescription];
    }
     ];
}

- (BOOL)isFederalRepresentative:(NSDictionary *)repDict {
    
    if ([repDict[@"officeName"]isEqualToString:@"U.S. Senate"] || [repDict[@"officeName"]isEqualToString:@"U.S. House"]) {
        return YES;
    }
    else {
        return NO;
    }
}

//- (void)createRepsFromCandidateId:(NSString *)candidateId WithCompletion:(void(^)(void))successBlock onError:(void(^)(NSError *error))errorBlock {
//
//}
#pragma mark - Create State Representatives

-(void)createStateRepresentativesFromLocation:(CLLocation *)location WithCompletion:(void (^)(void))successBlock onError:(void (^)(NSError *))errorBlock {
    
    [[RepsNetworkManager sharedInstance]getStateRepresentativesFromLocation:location WithCompletion:^(NSDictionary *results) {
        NSMutableArray *listOfStateRepresentatives = [[NSMutableArray alloc]init];
        
        BOOL firstRun = true;
        
        for (NSDictionary *resultDict in results) {
            StateRepresentative *stateRepresentative = [[StateRepresentative alloc] initWithData:resultDict];
            if (firstRun) {
                NSString *stateCode = stateRepresentative.stateCode;
                if (stateCode) {
                    StateRepresentative *governor = [self createGovernors:stateCode];
                    if (governor) {
                        [listOfStateRepresentatives addObject:governor];
                        firstRun = false;
                    }
                }
            }
            
            if (successBlock) {
                [listOfStateRepresentatives addObject:stateRepresentative];
                self.stateReps = listOfStateRepresentatives;
                successBlock();
            }
        }
        
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

- (StateRepresentative *)createGovernors:(NSString *)stateCode {
    
    StateRepresentative *governorRepresentative;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"stateGovernors" ofType:@"json"];
    NSData *governorJSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:nil];
    NSDictionary *governorDataDictionary = [NSJSONSerialization JSONObjectWithData:governorJSONData options:NSJSONReadingAllowFragments error:nil];
    for (NSDictionary *governor in governorDataDictionary) {
        if ([[governor valueForKey:@"state"]caseInsensitiveCompare:stateCode] == NSOrderedSame) {
            governorRepresentative = [[StateRepresentative alloc] initGovWithData:governor];
            break;
        }
    }
    return governorRepresentative;
}

#pragma mark - Create Local Representatives

- (void)createLocalRepsFromLocation:(CLLocation *)location {
    
    self.localReps = @[].mutableCopy;
    
    BOOL isLocationWithinPath = false;
    
    for (NSDictionary *district in self.localDistricts) {
        CGMutablePathRef path = CGPathCreateMutable();
        [self drawLocalDistrictPath:path fromDictionary:district];
        isLocationWithinPath = [self isLocation:location withinPath:path];
        CGPathRelease(path);
        if (isLocationWithinPath) {
            break;
        }
    }
    
    if (!isLocationWithinPath) {
        self.localReps = nil;
    }
}

- (void)drawLocalDistrictPath:(CGMutablePathRef)path fromDictionary: (NSDictionary *)district {
    
    // Parse out the council district from the data
    self.currentCouncilDistrict = [[district valueForKey:@"properties"]valueForKey:@"coundist"];
    // Parse out the geometry
    NSDictionary *geometry = [district valueForKey:@"geometry"];
    // Parse the polygons from the data
    NSArray *coordinateObjects = [geometry valueForKey:@"coordinates"];
    // For each polygon
    for (NSArray *array in coordinateObjects) {
        // The counter is here to check if its the initial point or not
        int counter = 0;
        for (NSArray *subArray in array) {
            for (NSArray *subSubArray in subArray) {
                double latitude = [subSubArray[1]doubleValue];
                double longitude = [subSubArray[0]doubleValue];
                if (counter == 0) {
                    CGPathMoveToPoint(path, nil, latitude, longitude);
                } else {
                    CGPathAddLineToPoint(path, nil, latitude, longitude);
                }
                counter++;
            }
        }
    }
    CGPathCloseSubpath(path);
}

- (BOOL)isLocation:(CLLocation *)location withinPath:(CGMutablePathRef)path {
    
    BOOL isLocationWithinPath = NO;
    self.isLocalRepsAvailable = NO;
    
    // Grab the latitude and longitude
    double currentLatitude = location.coordinate.latitude;
    double currentLongitude = location.coordinate.longitude;
    if (CGPathContainsPoint(path, nil, CGPointMake(currentLatitude,currentLongitude),false)) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:kCouncilMemberDataJSON ofType:@"json"];
        NSData *councilMemberJSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:nil];
        NSDictionary *councilMemberDataDictionary = [NSJSONSerialization JSONObjectWithData:councilMemberJSONData options:NSJSONReadingAllowFragments error:nil];
        NSDictionary *districts = [councilMemberDataDictionary objectForKey:@"districts"];
        
        for (int i = 0; i < districts.count; i++) {
            if (i + 1 == [self.currentCouncilDistrict intValue]) {
                isLocationWithinPath = YES;
                self.isLocalRepsAvailable = YES;
                LocalRepresentative *localRep = [[LocalRepresentative alloc] initWithData:districts[[NSString stringWithFormat:@"%d", i+1]]];
                [self.localReps addObject:localRep];
                [self createExtraNYCReps];
                
                return isLocationWithinPath;
            }
        }
    }
    return isLocationWithinPath;
}

- (void)createExtraNYCReps {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kNYCExtraRepsJSON ofType:@"json"];
    NSData *nycExtraRepsData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:nil];
    NSDictionary *nycExtraRepsDict = [NSJSONSerialization JSONObjectWithData:nycExtraRepsData options:NSJSONReadingAllowFragments error:nil];
    NSDictionary *reps = [nycExtraRepsDict objectForKey:@"reps"];
    for (id repData in reps) {
        LocalRepresentative *rep = [[LocalRepresentative alloc]initWithData:reps[repData]];
        [self.localReps addObject:rep];
    }
}

- (LocalRepresentative *)createBillDeBlasio {
    
    NSDictionary *deBlasioDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BilldeBlasio" ofType:@"plist"]];
    LocalRepresentative *billDeBlasio = [[LocalRepresentative alloc] initWithData:deBlasioDictionary];
    return billDeBlasio;
}

@end
