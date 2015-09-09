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
        self.listofStateLegislators = [NSMutableArray array];
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
        NSMutableArray *listofStateLegislators = [[NSMutableArray alloc]init];
                for (NSDictionary *resultDict in results) {
                    StateLegislator *stateLegislator = [[StateLegislator alloc] initWithData:resultDict];
                    [self assignStatePhotos:stateLegislator withCompletion:^{
                        if (successBlock) {
                            successBlock();
                            [listofStateLegislators addObject:stateLegislator];
                            self.listofStateLegislators = listofStateLegislators;
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadStateLegislatorTableView"
                                                                                object:nil];
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
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                NSManagedObjectContext *context = [appDelegate managedObjectContext];
                NSManagedObject *managedStateLegislator;
                managedStateLegislator = [NSEntityDescription insertNewObjectForEntityForName:@"Congressperson" inManagedObjectContext:context];
                [managedStateLegislator setValue:congressperson.photo forKey:@"photo"];
                [managedStateLegislator setValue:congressperson.firstName forKey:@"firstName"];
                [managedStateLegislator setValue:congressperson.lastName forKey:@"lastName"];
                NSError *error;
                [context save:&error];
                NSLog(@"Saving to cache");
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
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                NSManagedObjectContext *context = [appDelegate managedObjectContext];
                NSManagedObject *managedStateLegislator;
                managedStateLegislator = [NSEntityDescription insertNewObjectForEntityForName:@"StateLegislator" inManagedObjectContext:context];
                [managedStateLegislator setValue:stateLegislator.photo forKey:@"photo"];
                [managedStateLegislator setValue:stateLegislator.firstName forKey:@"firstName"];
                [managedStateLegislator setValue:stateLegislator.lastName forKey:@"lastName"];
                NSError *error;
                [context save:&error];
                NSLog(@"Saving to cache");
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
