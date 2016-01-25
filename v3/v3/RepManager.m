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
#import "Congressperson.h"
#import "StateLegislator.h"
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
        self.listOfCongressmen = [NSArray array];
        self.listOfStateLegislators = [NSMutableArray array];
        self.index = 0;
    }
    return self;
}

- (void)createCongressmenFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                              onError:(void(^)(NSError *error))errorBlock {
    
    [[NetworkManager sharedInstance]getCongressmenFromLocation:location WithCompletion:^(NSDictionary *results) {
        NSMutableArray *listOfCongressmen = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in [results valueForKey:@"results"]) {
            Congressperson *congressperson = [[Congressperson alloc] initWithData:resultDict];
            [self assignCongressPhotos:congressperson withCompletion:^{
                if (successBlock) {
                    [listOfCongressmen addObject:congressperson];
                    self.listOfCongressmen = listOfCongressmen;
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

-(void)createStateLegislatorsFromLocation:(CLLocation *)location WithCompletion:(void (^)(void))successBlock onError:(void (^)(NSError *))errorBlock {
    
    [[NetworkManager sharedInstance]getStateLegislatorsFromLocation:location WithCompletion:^(NSDictionary *results) {
        NSMutableArray *listOfStateLegislators = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in results) {
            StateLegislator *stateLegislator = [[StateLegislator alloc] initWithData:resultDict];
            [self assignStatePhotos:stateLegislator withCompletion:^{
                if (successBlock) {
                    [listOfStateLegislators addObject:stateLegislator];
                    self.listOfStateLegislators = listOfStateLegislators;
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

- (void)createNYCRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void (^)(void))successBlock onError:(void (^)(NSError *error))errorBlock {
    [[NetworkManager sharedInstance]getNYCCouncilMemberFromLocation:location WithCompletion:^(NSArray *results) {
        if (successBlock) {
            NSMutableArray *listOfNYCRepresentatives = [[NSMutableArray alloc]init];
            NSArray *councilMembers = [results valueForKey:@"officials"];
            NSArray *offices = [results valueForKey:@"offices"];
            for (id office in offices) {
                if ([[office valueForKey:@"name"]containsString:@"Council"]){
                    NSArray *officialIndices = [office valueForKey:@"officialIndices"];
                    NSInteger index = [officialIndices[0] integerValue];
                    NYCRepresentative  *nycRepresentative = [[NYCRepresentative alloc]initWithData:councilMembers[index]];
                    [listOfNYCRepresentatives addObject:nycRepresentative];
                    self.listOfNYCRepresentatives = listOfNYCRepresentatives;
                    successBlock();
                }
            }
        }
    } onError:^(NSError *error) {
        NSLog(@"ERROR");
    }];
}

- (void)assignCongressPhotos:(Congressperson*)congressperson withCompletion:(void(^)(void))successBlock
                     onError:(void(^)(NSError *error))errorBlock {
    
    Congressperson *cachedCongressperson = [[CacheManager sharedInstance]fetchRepWithEntityName:@"Congressperson" withFirstName:congressperson.firstName withLastName:congressperson.lastName];
    if (cachedCongressperson) {
        congressperson.photo = cachedCongressperson.photo;
        successBlock();
    }
    else {
        [[NetworkManager sharedInstance]getCongressPhotos:congressperson.bioguide withCompletion:^(UIImage *results) {
            congressperson.photo = UIImagePNGRepresentation(results);
            if (successBlock) {
                successBlock();
                [[CacheManager sharedInstance]cacheRepresentative:congressperson withEntityName:@"Congressperson"];
            }
        } onError:^(NSError *error) {
            errorBlock(error);
        }];
    }
}

- (void)assignStatePhotos:(StateLegislator*)stateLegislator withCompletion:(void(^)(void))successBlock
                  onError:(void(^)(NSError *error))errorBlock {
    
    StateLegislator *cachedStateLegislator = [[CacheManager sharedInstance]fetchRepWithEntityName:@"StateLegislator" withFirstName:stateLegislator.firstName withLastName:stateLegislator.lastName];
    
    if (cachedStateLegislator) {
        stateLegislator.photo = cachedStateLegislator.photo;
        successBlock();
    }
    else {
        NSLog(@"Firing network request");
        [[NetworkManager sharedInstance]getStatePhotos:stateLegislator.photoURL withCompletion:^(UIImage *results) {
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

- (void)assignInfluenceExplorerID:(Congressperson*)congressperson withCompletion:(void(^)(void))successBlock
                          onError:(void(^)(NSError *error))errorBlock {
    [[NetworkManager sharedInstance]idLookup:congressperson.bioguide withCompletion:^(NSArray *results) {
        congressperson.influenceExplorerID =  [results valueForKey:@"id"][0];
        if (successBlock) {
            successBlock();
        }
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)assignTopContributors:(Congressperson*)congressperson withCompletion:(void(^)(void))successBlock
                      onError:(void(^)(NSError *error))errorBlock {
    [[NetworkManager sharedInstance]getTopContributors:congressperson.crpID withCompletion:^(NSDictionary *results) {
        NSDictionary *response = [results valueForKey:@"response"];
        NSArray *contributors = [[response valueForKey:@"contributors"]valueForKey:@"contributor"];
        congressperson.topContributors = contributors;
        successBlock();
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)assignTopIndustries:(Congressperson*)congressperson withCompletion:(void(^)(void))successBlock
                    onError:(void(^)(NSError *error))errorBlock {
    [[NetworkManager sharedInstance]getTopIndustries:congressperson.influenceExplorerID withCompletion:^(NSArray *results) {
        congressperson.topIndustries = results;
        successBlock();
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}
@end