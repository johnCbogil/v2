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
        self.listOfFederalRepresentatives = [self checkCacheForRepresentatives:kCachedFederalRepresentatives];
        if (!self.listOfFederalRepresentatives.count > 0) {
            // MAKE NETWORK REQUEST
            [[LocationService sharedInstance]startUpdatingLocation];
        }
        else return self.listOfFederalRepresentatives;
    }
    else if (index == 1) {
        self.listOfStateRepresentatives = [self checkCacheForRepresentatives:kCachedStateRepresentatives];
    }
    else if (index == 2) {
        self.listOfNYCRepresentatives = [self checkCacheForRepresentatives:kCachedNYCRepresentatives];
    }
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        [self createFederalRepresentativesFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
            NSLog(@"Federal Reps: %ld",self.listOfFederalRepresentatives.count);
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
        } onError:nil];
        
    }
}


#pragma mark - Check Cache For Representatives

- (NSArray *)checkCacheForRepresentatives:(NSString *)representativeType {
    return [[CacheManager sharedInstance] checkUserDefaultsForRepresentative:representativeType];
}

#pragma mark - Create Federal Representatives

- (void)createFederalRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                              onError:(void(^)(NSError *error))errorBlock {
    
    [[NetworkManager sharedInstance]getFederalRepresentativesFromLocation:location WithCompletion:^(NSDictionary *results) {
        
        NSMutableArray *listOfFederalRepresentatives = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in [results valueForKey:@"results"]) {
            FederalRepresentative *federalRepresentative = [[FederalRepresentative alloc] initWithData:resultDict];
            [self assignFederalRepresentativePhoto:federalRepresentative withCompletion:^{
                if (successBlock) {
                    [listOfFederalRepresentatives addObject:federalRepresentative];
                    self.listOfFederalRepresentatives = listOfFederalRepresentatives;
                    
                    successBlock();
                }
            } onError:^(NSError *error) {
                errorBlock(error);
            }];
        }
//        self.listOfFederalRepresentatives = listOfFederalRepresentatives;
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.listOfFederalRepresentatives] forKey:kCachedFederalRepresentatives];
        if (successBlock) {
            successBlock();
        }
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)assignFederalRepresentativePhoto:(FederalRepresentative *)federalRepresentative withCompletion:(void(^)(void))successBlock
                                 onError:(void(^)(NSError *error))errorBlock {
    
    FederalRepresentative *cachedFederalRepresentative = [[CacheManager sharedInstance]fetchRepPhotoWithEntityName:kFederalRepresentative withFirstName:federalRepresentative.firstName withLastName:federalRepresentative.lastName];
    if (cachedFederalRepresentative) {
        federalRepresentative.photo = cachedFederalRepresentative.photo;
        successBlock();
    }
    else {
        [[NetworkManager sharedInstance]getFederalRepresentativePhoto:federalRepresentative.bioguide withCompletion:^(UIImage *results) {
            federalRepresentative.photo = UIImagePNGRepresentation(results);
            if (successBlock) {
                successBlock();
                [[CacheManager sharedInstance]cacheRepresentativePhoto:federalRepresentative withEntityName:kFederalRepresentative];
            }
        } onError:^(NSError *error) {
            errorBlock(error);
        }];
    }
}

#pragma mark - Create State Representatives

-(void)createStateRepresentativesFromLocation:(CLLocation *)location WithCompletion:(void (^)(void))successBlock onError:(void (^)(NSError *))errorBlock {
    
    [[NetworkManager sharedInstance]getStateRepresentativesFromLocation:location WithCompletion:^(NSDictionary *results) {
        NSMutableArray *listOfStateRepresentatives = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in results) {
            StateRepresentative *stateRepresentative = [[StateRepresentative alloc] initWithData:resultDict];
            [self assignStatePhotos:stateRepresentative withCompletion:^{
                if (successBlock) {
                    [listOfStateRepresentatives addObject:stateRepresentative];
                    successBlock();
                }
            } onError:^(NSError *error) {
                errorBlock(error);
            }];
        }
        self.listOfStateRepresentatives = listOfStateRepresentatives;
        successBlock();
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)assignStatePhotos:(StateRepresentative *)stateRepresentative withCompletion:(void(^)(void))successBlock
                  onError:(void(^)(NSError *error))errorBlock {
    
    StateRepresentative *cachedStateRepresentative = [[CacheManager sharedInstance]fetchRepPhotoWithEntityName:kStateRepresentative withFirstName:stateRepresentative.firstName withLastName:stateRepresentative.lastName];
    
    if (cachedStateRepresentative) {
        stateRepresentative.photo = cachedStateRepresentative.photo;
        successBlock();
    }
    else {
        NSLog(@"Firing network request");
        [[NetworkManager sharedInstance]getStateRepresentativePhoto:stateRepresentative.photoURL withCompletion:^(UIImage *results) {
            stateRepresentative.photo = UIImagePNGRepresentation(results);
            if (successBlock) {
                successBlock();
                if (![[results accessibilityIdentifier] isEqualToString:@"MissingRep"]) {
                    [[CacheManager sharedInstance]cacheRepresentativePhoto:stateRepresentative withEntityName:kStateRepresentative];
                }
            }
        } onError:^(NSError *error) {
            errorBlock(error);
        }];
    }
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
                // Assign NYC photos here
                [self assignNYCRepresentativePhotos:nycRepresentative withCompletion:^{
                    if (nycRepresentative.photo) {
                        NSLog(@"there is a photo");
                    }
                    else {
                        NSLog(@"There is no photo");
                    }
                    [listOfNYCRepresentatives addObject:nycRepresentative];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
                } onError:^(NSError *error) {
                    NSLog(@"nyc photo error");
                }];
                self.listOfNYCRepresentatives = listOfNYCRepresentatives;
                return isLocationWithinPath;
            }
        }
    }
    return isLocationWithinPath;
}

- (void)assignNYCRepresentativePhotos:(NYCRepresentative *)nycRepresentative withCompletion:(void(^)(void))successBlock
                              onError:(void(^)(NSError *error))errorBlock {

    NYCRepresentative *cachedNYCRepresentative = [[CacheManager sharedInstance]fetchRepPhotoWithEntityName:kNYCRepresentative withFirstName:nycRepresentative.name withLastName:@""];
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
                    [[CacheManager sharedInstance]cacheRepresentativePhoto:nycRepresentative withEntityName:kNYCRepresentative];
                }
            }
        } onError:^(NSError *error) {
            errorBlock(error);
        }];
    }
}

@end