
//  CacheManager.m
//  v3
//
//  Created by John Bogil on 9/9/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "CacheManager.h"
#import "FederalRepresentative.h"
#import "StateRepresentative.h"
#import "RepManager.h"
#import "LocationService.h"
#import "NYCRepresentative.h"
#import "VoicesConstants.h"

@interface CacheManager ()
@property (strong, nonatomic) NSManagedObjectContext *context;
@end

@implementation CacheManager
+ (CacheManager *)sharedInstance {
    static CacheManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.context = [appDelegate managedObjectContext];
    }
    return self;
}

- (id)fetchRepWithEntityName:(NSString*)entityName withFirstName:(NSString*)firstName withLastName:(NSString*)lastName {
    NSLog(@"Searching cache");
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *predicate;
    if ([entityName isEqualToString:kNYCRepresentative]) {
        predicate =[NSPredicate predicateWithFormat:@"(name = %@)", firstName];
    }
    else {
        predicate =[NSPredicate predicateWithFormat:@"(firstName = %@ && lastName = %@)",firstName, lastName];
    }
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *cachedObjects = [self.context executeFetchRequest:request
                                                         error:&error];
    if (cachedObjects.count) {
        NSLog(@"Object found in cache");
        return cachedObjects[0];
    }
    else {
        return nil;
    }
}

- (void)cacheRepresentative:(id)representative withEntityName:(NSString*)entityName {
    if([entityName isEqualToString:kFederalRepresentative]) {
        FederalRepresentative *federalRepresentative = representative;
        NSManagedObject *managedFederalRepresentative;
        managedFederalRepresentative = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
        [managedFederalRepresentative setValue:federalRepresentative.photo forKey:@"photo"];
        [managedFederalRepresentative setValue:federalRepresentative.firstName forKey:@"firstName"];
        [managedFederalRepresentative setValue:federalRepresentative.lastName forKey:@"lastName"];
    }
    else if ([entityName isEqualToString:kStateRepresentative]) {
        StateRepresentative *stateRepresentative = representative;
        NSManagedObject *managedStateRepresentative;
        managedStateRepresentative = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
        [managedStateRepresentative setValue:stateRepresentative.photo forKey:@"photo"];
        [managedStateRepresentative setValue:stateRepresentative.firstName forKey:@"firstName"];
        [managedStateRepresentative setValue:stateRepresentative.lastName forKey:@"lastName"];
    }
    else if ([entityName isEqualToString:kNYCRepresentative]) {
        NYCRepresentative *nycRepresentative = representative;
        NSManagedObject *managedNYCRepresentative;
        managedNYCRepresentative = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
        [managedNYCRepresentative setValue:nycRepresentative.photo forKey:@"photo"];
        [managedNYCRepresentative setValue:nycRepresentative.name forKey:@"name"];
    }
    NSError *coreDataSaveerror;
    [self.context save:&coreDataSaveerror];
    NSLog(@"Saving to cache");
}

- (void)checkCacheForRepresentative:(NSString*)representativeType {
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingCachedRepresentatives = [currentDefaults objectForKey:representativeType];
    if (dataRepresentingCachedRepresentatives != nil) {
        NSArray *oldCachedRepresentatives = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingCachedRepresentatives];
        if (oldCachedRepresentatives != nil){
            
            // THESE VALUES SHOULD BE COSNTANTS
            if ([representativeType isEqualToString:kCachedFederalRepresentatives]) {
                [RepManager sharedInstance].listOfFederalRepresentatives = [[NSMutableArray alloc] initWithArray:oldCachedRepresentatives];
            }
            else if ([representativeType isEqualToString:kCachedStateRepresentatives]) {
                [RepManager sharedInstance].listOfStateRepresentatives = [[NSMutableArray alloc]initWithArray:oldCachedRepresentatives];
            }
            else if ([representativeType isEqualToString:kCachedNYCRepresentatives]){
                [RepManager sharedInstance].listOfNYCRepresentatives = [[NSMutableArray alloc]initWithArray:oldCachedRepresentatives];
            }
        }
    }
    
    // NOT SURE I NEED THIS ELSE BLOCK
    else {
        if ([representativeType isEqualToString:kCachedFederalRepresentatives]) {
            [RepManager sharedInstance].listOfFederalRepresentatives = [[NSMutableArray alloc]init];
        }
        else if ([representativeType isEqualToString:kCachedStateRepresentatives]) {
            [RepManager sharedInstance].listOfStateRepresentatives = [[NSMutableArray alloc]init];
        }
        else if ([representativeType isEqualToString:kCachedNYCRepresentatives]){
            [RepManager sharedInstance].listOfNYCRepresentatives = [[NSMutableArray alloc]init];
        }
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [[LocationService sharedInstance]startUpdatingLocation];
        }
    }
}
@end