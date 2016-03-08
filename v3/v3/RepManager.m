//
//  RepManager.m
//  v3
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
        self.listOfFederalRepresentatives = [NSArray array];
        self.listOfStateRepresentatives = [NSMutableArray array];
        self.index = 0;
    }
    return self;
}

- (void)createFederalRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                              onError:(void(^)(NSError *error))errorBlock {
    
    [[NetworkManager sharedInstance]getFederalRepresentativesFromLocation:location WithCompletion:^(NSDictionary *results) {
        NSMutableArray *listOfFederalRepresentatives = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in [results valueForKey:@"results"]) {
            FederalRepresentative *federalRepresentative = [[FederalRepresentative alloc] initWithData:resultDict];
            [self assignFederalRepresentativePhoto:federalRepresentative withCompletion:^{
                if (successBlock) {
                    [listOfFederalRepresentatives addObject:federalRepresentative];
                    // THIS PROBABLY DOESNT NEED TO BE HERE
                    self.listOfFederalRepresentatives = listOfFederalRepresentatives;
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateInformationLabel" object:nil];
                    successBlock();
                }
            } onError:^(NSError *error) {
                errorBlock(error);
            }];
        }
        if (successBlock) {
            successBlock();
        }
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

-(void)createStateRepresentativesFromLocation:(CLLocation *)location WithCompletion:(void (^)(void))successBlock onError:(void (^)(NSError *))errorBlock {
    
    [[NetworkManager sharedInstance]getStateRepresentativesFromLocation:location WithCompletion:^(NSDictionary *results) {
        NSMutableArray *listOfStateRepresentatives = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in results) {
            StateRepresentative *stateLegislator = [[StateRepresentative alloc] initWithData:resultDict];
            [self assignStatePhotos:stateLegislator withCompletion:^{
                if (successBlock) {
                    [listOfStateRepresentatives addObject:stateLegislator];
                    self.listOfStateRepresentatives = listOfStateRepresentatives;
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateInformationLabel" object:nil];
                    successBlock();
                }
            } onError:^(NSError *error) {
                errorBlock(error);
            }];
        }
        successBlock();
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)assignFederalRepresentativePhoto:(FederalRepresentative *)federalRepresentative withCompletion:(void(^)(void))successBlock
                     onError:(void(^)(NSError *error))errorBlock {
    
    FederalRepresentative *cachedFederalRepresentative = [[CacheManager sharedInstance]fetchRepWithEntityName:@"FederalRepresentative" withFirstName:federalRepresentative.firstName withLastName:federalRepresentative.lastName];
    if (cachedFederalRepresentative) {
        federalRepresentative.photo = cachedFederalRepresentative.photo;
        successBlock();
    }
    else {
        [[NetworkManager sharedInstance]getFederalRepresentativePhoto:federalRepresentative.bioguide withCompletion:^(UIImage *results) {
            federalRepresentative.photo = UIImagePNGRepresentation(results);
            if (successBlock) {
                successBlock();
                [[CacheManager sharedInstance]cacheRepresentative:federalRepresentative withEntityName:@"FederalRepresentative"];
            }
        } onError:^(NSError *error) {
            errorBlock(error);
        }];
    }
}

- (void)assignStatePhotos:(StateRepresentative *)stateLegislator withCompletion:(void(^)(void))successBlock
                  onError:(void(^)(NSError *error))errorBlock {
    
    StateRepresentative *cachedStateRepresentative = [[CacheManager sharedInstance]fetchRepWithEntityName:@"StateLegislator" withFirstName:stateLegislator.firstName withLastName:stateLegislator.lastName];
    
    if (cachedStateRepresentative) {
        stateLegislator.photo = cachedStateRepresentative.photo;
        successBlock();
    }
    else {
        NSLog(@"Firing network request");
        [[NetworkManager sharedInstance]getStateRepresentativePhoto:stateLegislator.photoURL withCompletion:^(UIImage *results) {
            stateLegislator.photo = UIImagePNGRepresentation(results);
            if (successBlock) {
                successBlock();
                if (![[results accessibilityIdentifier] isEqualToString:@"MissingRep"]) {
                    [[CacheManager sharedInstance]cacheRepresentative:stateLegislator withEntityName:@"StateLegislator"];
                }
            }
        } onError:^(NSError *error) {
            errorBlock(error);
        }];
    }
}

// THIS NEEDS TO BE OPTIMIZED, A LOT
- (void)createNYCRepsFromLocation:(CLLocation*)location {
    BOOL isLocationWithinPath = false;
    
    // Parse the csv file into json
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:((AppDelegate*)[UIApplication sharedApplication].delegate).dataSetPathWithComponent encoding:NSUTF8StringEncoding error:NULL];
    NSError *error =  nil;
    NSDictionary *jsonDataDict = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    // Parse out the districts from the rest of the data
    NSArray *districts = [jsonDataDict valueForKey:@"features"];
    for (NSDictionary *district in districts) {
        CGMutablePathRef path = [self drawNYCDistrictPathFromDictionary:district];
        isLocationWithinPath = [self isLocation:location withinPath:path];
        if (isLocationWithinPath) {
            break;
        }
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
        // idk
        for (NSArray *subArray in array) {
            // idk
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
                // Assign NYC photos here
                [self assignNYCRepresentativePhotos:nycRepresentative withCompletion:^{
                    if (nycRepresentative.photo) {
                        NSLog(@"there is a photo");
                    }
                    else {
                        NSLog(@"There is no photo");
                    }
                    
                    [listOfNYCRepresentatives addObject:nycRepresentative];
                    self.listOfNYCRepresentatives = listOfNYCRepresentatives;
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
                    
                } onError:^(NSError *error) {
                    NSLog(@"nyc photo error");
                }];
                return isLocationWithinPath;
            }
        }
    }
    return isLocationWithinPath;
}

- (void)assignNYCRepresentativePhotos:(NYCRepresentative *)nycRepresentative withCompletion:(void(^)(void))successBlock
                              onError:(void(^)(NSError *error))errorBlock {
    
    NYCRepresentative *cachedNYCRepresentative = [[CacheManager sharedInstance]fetchRepWithEntityName:@"NYCRepresentative" withFirstName:nycRepresentative.name withLastName:@""];
    if (cachedNYCRepresentative) {
        nycRepresentative.photo = cachedNYCRepresentative.photo;
        successBlock();
    }
    else {
        NSLog(@"Firing nyc photo request");
        [[NetworkManager sharedInstance]getNYCRepresentativePhotos:nycRepresentative.photoURL withCompletion:^(UIImage *results) {
            nycRepresentative.photo = UIImagePNGRepresentation(results);
            successBlock();
            if (successBlock) {
                if (![[results accessibilityIdentifier] isEqualToString:@"MissingRep"]) {
                    [[CacheManager sharedInstance]cacheRepresentative:nycRepresentative withEntityName:@"NYCRepresentative"];
                }
            }
        } onError:^(NSError *error) {
            errorBlock(error);
        }];
    }
}


@end