//
//  RepManager.m
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RepManager.h"
#import "NetworkManager.h"
#import "Congressperson.h"
#import "StateLegislator.h"
#import "LocationService.h"
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
        self.listofStateLegislators = [NSArray array];
    }
    return self;
}

- (void)createCongressmenFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                  onError:(void(^)(NSError *error))errorBlock {
    
    [[NetworkManager sharedInstance]getCongressmenFromLocation:location WithCompletion:^(NSDictionary *results) {
        
        NSMutableArray *listOfCongressmen = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in [results valueForKey:@"results"]) {
            // THE CORRECT DATA IS BEING PULLED DOWN FOR SEARCHES DURING SEARCH BUG
            Congressperson *congressperson = [[Congressperson alloc] initWithData:resultDict];
            [self assignCongressPhotos:congressperson withCompletion:^{
                if (successBlock) {
                    [listOfCongressmen addObject:congressperson];
                    self.listOfCongressmen = listOfCongressmen;
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

- (void)createCongressmenFromQuery:(NSString*)query WithCompletion:(void(^)(void))successBlock
                              onError:(void(^)(NSError *error))errorBlock {
    
    [[NetworkManager sharedInstance]getCongressmenFromQuery:query WithCompletion:^(NSDictionary *results) {
        
        NSMutableArray *listOfCongressmen = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in [results valueForKey:@"results"]) {
            Congressperson *congressperson = [[Congressperson alloc] initWithData:resultDict];
            [self assignCongressPhotos:congressperson withCompletion:^{
                if (successBlock) {
                    [listOfCongressmen addObject:congressperson];
                    self.listOfCongressmen = listOfCongressmen;
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

- (void)createStateLegislators:(void(^)(void))successBlock
                       onError:(void(^)(NSError *error))errorBlock {
    [[NetworkManager sharedInstance]getStateLegislatorsWithCompletion:^(NSDictionary *results) {
        NSMutableArray *listofStateLegislators = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in results) {
            StateLegislator *stateLegislator = [[StateLegislator alloc] initWithData:resultDict];
            [self assignStatePhotos:stateLegislator withCompletion:^{
                if (successBlock) {
                    successBlock();
                    [listofStateLegislators addObject:stateLegislator];
                    self.listofStateLegislators = listofStateLegislators;
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

- (void)assignCongressPhotos:(Congressperson*)congressperson withCompletion:(void(^)(void))successBlock
                     onError:(void(^)(NSError *error))errorBlock {
    [[NetworkManager sharedInstance]getCongressPhotos:congressperson.bioguide withCompletion:^(UIImage *results) {
        congressperson.photo = results;
        if (successBlock) {
            successBlock();
        }
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)assignStatePhotos:(StateLegislator*)stateLegislator withCompletion:(void(^)(void))successBlock
                  onError:(void(^)(NSError *error))errorBlock {
    [[NetworkManager sharedInstance]getStatePhotos:stateLegislator.photoURL withCompletion:^(UIImage *results) {
        stateLegislator.photo = results;
        if (successBlock) {
            successBlock();
        }
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
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
    [[NetworkManager sharedInstance]getTopContributors:congressperson.influenceExplorerID withCompletion:^(NSArray *results) {
        congressperson.topContributors = results;
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
