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
#import "NYCRepresentative.h"
#import "LocationService.h"

@interface RepsManager()

@property (strong, nonatomic) NSArray *fedReps;
@property (strong, nonatomic) NSArray *stateReps;
@property (strong, nonatomic) NSString *currentCouncilDistrict;

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
        [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
        self.isLocalRepsAvailable = YES;
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

#pragma mark - Location Monitor

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        
        [self createFederalRepresentativesFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error){
            NSLog(@"%@",[error localizedDescription]);
        }];
        
        [self createStateRepresentativesFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error) {
            NSLog(@"%@",[error localizedDescription]);
        }];
        
        [self createNYCRepsFromLocation:[LocationService sharedInstance].currentLocation];
    }
}

#pragma mark - Create Federal Representatives

- (void)createFederalRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                                         onError:(void(^)(NSError *error))errorBlock {
    
    [[RepsNetworkManager sharedInstance]getFederalRepresentativesFromLocation:location WithCompletion:^(NSDictionary *results) {
        
        // THIS FEELS REDUNDANT
        NSMutableArray *listOfFederalRepresentatives = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in [results valueForKey:@"results"]) {
            FederalRepresentative *federalRepresentative = [[FederalRepresentative alloc] initWithData:resultDict];
            [listOfFederalRepresentatives addObject:federalRepresentative];
            self.fedReps = listOfFederalRepresentatives;
            successBlock();
        }
        
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

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

#pragma mark - Create NYC Representatives

- (void)createNYCRepsFromLocation:(CLLocation *)location {
    
    self.localReps = @[].mutableCopy;
        
    BOOL isLocationWithinPath = false;
    
    for (NSDictionary *district in self.nycDistricts) {
        CGMutablePathRef path = CGPathCreateMutable();
        [self drawNYCDistrictPath:path fromDictionary:district];
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

- (void)drawNYCDistrictPath:(CGMutablePathRef)path fromDictionary: (NSDictionary *)district {
    
    // Parse out the council district from the data
    self.currentCouncilDistrict = [[district valueForKey:@"properties"]valueForKey:@"coundist"];
    NSLog(@"%@", self.currentCouncilDistrict);
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
        NSData *nycCouncilMemberJSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:nil];
        NSDictionary *nycCouncilMemberDataDictionary = [NSJSONSerialization JSONObjectWithData:nycCouncilMemberJSONData options:NSJSONReadingAllowFragments error:nil];
        NSDictionary *districts = [nycCouncilMemberDataDictionary objectForKey:@"districts"];
        
        for (int i = 0; i < districts.count; i++) {
            if (i + 1 == [self.currentCouncilDistrict intValue]) {
                isLocationWithinPath = YES;
                self.isLocalRepsAvailable = YES;
                NYCRepresentative *nycRep = [[NYCRepresentative alloc] initWithData:districts[[NSString stringWithFormat:@"%d", i+1]]];
                [self.localReps addObject:nycRep];
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
        NYCRepresentative *rep = [[NYCRepresentative alloc]initWithData:reps[repData]];
        [self.localReps addObject:rep];
    }
}

- (NYCRepresentative *)createBillDeBlasio {
    
    NSDictionary *deBlasioDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BilldeBlasio" ofType:@"plist"]];
    NYCRepresentative *billDeBlasio = [[NYCRepresentative alloc] initWithData:deBlasioDictionary];
    return billDeBlasio;
}

@end
