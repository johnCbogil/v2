//
//  RepManager.m
//  Voices
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RepManager.h"
#import "NetworkManager.h"
#import "FederalRepresentative.h"
#import "StateRepresentative.h"
#import "NYCRepresentative.h"
#import "LocationService.h"
#import "AppDelegate.h"
#import "CacheManager.h"
#import "VoicesConstants.h"

@implementation RepManager

+ (RepManager *)sharedInstance {
    static RepManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (NSArray *)createRepsForIndex:(NSInteger)index {
    if (index == 0) {
        self.listOfFederalRepresentatives = [self fetchRepsFromCache:kCachedFederalRepresentatives];
        
        if (self.listOfFederalRepresentatives.count > 0) {
            return self.listOfFederalRepresentatives;
        }
        else {
            [[LocationService sharedInstance]startUpdatingLocation];
        }
    }
    else if (index == 1) {
        self.listOfStateRepresentatives = [self fetchRepsFromCache:kCachedStateRepresentatives];
        
        if (self.listOfStateRepresentatives.count > 0) {
            return self.listOfStateRepresentatives;
        }
    }
    else if (index == 2) {
        self.listOfNYCRepresentatives = [self fetchRepsFromCache:kCachedNYCRepresentatives];
        
        if (self.listOfNYCRepresentatives.count > 0) {
            return self.listOfNYCRepresentatives;
        }
    }
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        // NEED TO HANDLE ERROR
        [self createFederalRepresentativesFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error){
            NSLog(@"%@",[error localizedDescription]);
        }];
        
        // NEED TO HANDLE ERROR
        [self createStateRepresentativesFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error) {
            NSLog(@"%@",[error localizedDescription]);
        }];
        
        // NEED TO ADD COMPLETION BLOCK
        [self createNYCRepsFromLocation:[LocationService sharedInstance].currentLocation];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
    }
}

- (void)startUpdatingLocation {
    [[LocationService sharedInstance]startUpdatingLocation];
}


#pragma mark - Check Cache For Representatives

- (NSArray *)fetchRepsFromCache:(NSString *)representativeType {
    return [[CacheManager sharedInstance] fetchRepsFromCache:representativeType];
}

#pragma mark - Create Federal Representatives

- (void)createFederalRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                                         onError:(void(^)(NSError *error))errorBlock {
    
    [[NetworkManager sharedInstance]getFederalRepresentativesFromLocation:location WithCompletion:^(NSDictionary *results) {
        
        // REPLACE THIS NEW ARRAY WITH THE PROPERTY
        NSMutableArray *listOfFederalRepresentatives = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in [results valueForKey:@"results"]) {
            FederalRepresentative *federalRepresentative = [[FederalRepresentative alloc] initWithData:resultDict];
            [listOfFederalRepresentatives addObject:federalRepresentative];
            self.listOfFederalRepresentatives = listOfFederalRepresentatives;
                            // MOVE THIS INTO THE CACHE MANAGER
            [[CacheManager sharedInstance]saveRepsToCache:self.listOfFederalRepresentatives forKey:kCachedFederalRepresentatives];
            successBlock();
        }
        
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark - Create State Representatives

-(void)createStateRepresentativesFromLocation:(CLLocation *)location WithCompletion:(void (^)(void))successBlock onError:(void (^)(NSError *))errorBlock {
    
    [[NetworkManager sharedInstance]getStateRepresentativesFromLocation:location WithCompletion:^(NSDictionary *results) {
        NSMutableArray *listOfStateRepresentatives = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in results) {
            StateRepresentative *stateRepresentative = [[StateRepresentative alloc] initWithData:resultDict];
            if (successBlock) {
                [listOfStateRepresentatives addObject:stateRepresentative];
                self.listOfStateRepresentatives = listOfStateRepresentatives;
                                // MOVE THIS INTO THE CACHE MANAGER
                [[CacheManager sharedInstance]saveRepsToCache:self.listOfStateRepresentatives forKey:kCachedStateRepresentatives];
                successBlock();
            }
        }
        
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark - Create NYC Representatives

- (void)createNYCRepsFromLocation:(CLLocation*)location {
    
    BOOL isLocationWithinPath = false;
    
    for (NSDictionary *district in self.nycDistricts) {
        CGMutablePathRef path = [self drawNYCDistrictPathFromDictionary:district];
        
        isLocationWithinPath = [self isLocation:location withinPath:path];
        
        if (isLocationWithinPath) {
            break;
        }
    }
    
    if (!isLocationWithinPath) {
        
        //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"alert"  message:@"error" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        //        [alert show];
        
    }
}

- (CGMutablePathRef)drawNYCDistrictPathFromDictionary: (NSDictionary *)district {
    
    // Create a path
    CGMutablePathRef path = CGPathCreateMutable();
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
    return path;
}

- (BOOL)isLocation:(CLLocation *)location withinPath:(CGMutablePathRef)path {
    
    BOOL isLocationWithinPath;
    
    // Grab the latitude and longitude
    double currentLatitude = location.coordinate.latitude;
    double currentLongitude = location.coordinate.longitude;
    if (CGPathContainsPoint(path, nil, CGPointMake(currentLatitude,currentLongitude),false)) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"NYCCouncilMembers" ofType:@"csv"];
        NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
        NSArray* rows = [fileContents componentsSeparatedByString:@"\n"];
        for (NSString *member in rows) {
            if ([rows indexOfObject:member] == [self.currentCouncilDistrict integerValue]-1) {
                isLocationWithinPath = YES;
                NSMutableArray *listOfNYCRepresentatives = [[NSMutableArray alloc]init];
                NSArray *memberData = [member componentsSeparatedByString:@","];
                NSLog(@"%@", memberData);
                NYCRepresentative  *nycRepresentative = [[NYCRepresentative alloc]initWithData:memberData];
                [listOfNYCRepresentatives addObject:nycRepresentative];
                self.listOfNYCRepresentatives = listOfNYCRepresentatives;
                
                // MOVE THIS INTO THE CACHE MANAGER
                [[CacheManager sharedInstance]saveRepsToCache:self.listOfNYCRepresentatives forKey:kCachedNYCRepresentatives];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
                
                return isLocationWithinPath;
            }
        }
    }
    return isLocationWithinPath;
}

@end