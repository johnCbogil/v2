
//  CacheManager.m
//  v2
//
//  Created by John Bogil on 9/9/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "CacheManager.h"
#import "Congressperson.h"
#import "StateLegislator.h"
#import "RepManager.h"
#import "LocationService.h"

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

- (id)fetchRepWithEntityName:(NSString*)entityName withFirstName:(NSString*)firstName withLastName:(NSString*)lastName{
    NSLog(@"Searching cache");
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(firstName = %@ && lastName = %@)",firstName, lastName];
    [request setPredicate:pred];
    
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
    if([entityName isEqualToString:@"Congressperson"]) {
        Congressperson *congressperson = representative;
        NSManagedObject *managedCongressperson;
        managedCongressperson = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
        [managedCongressperson setValue:congressperson.photo forKey:@"photo"];
        [managedCongressperson setValue:congressperson.firstName forKey:@"firstName"];
        [managedCongressperson setValue:congressperson.lastName forKey:@"lastName"];
    }
    else if ([entityName isEqualToString:@"StateLegislator"]) {
        StateLegislator *stateLegislator = representative;
        NSManagedObject *managedStateLegislator;
        managedStateLegislator = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
        [managedStateLegislator setValue:stateLegislator.photo forKey:@"photo"];
        [managedStateLegislator setValue:stateLegislator.firstName forKey:@"firstName"];
        [managedStateLegislator setValue:stateLegislator.lastName forKey:@"lastName"];
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
            if ([representativeType isEqualToString:@"cachedCongresspersons"]) {
                [RepManager sharedInstance].listOfCongressmen = [[NSMutableArray alloc] initWithArray:oldCachedRepresentatives];
            }
            else {
                [RepManager sharedInstance].listofStateLegislators = [[NSMutableArray alloc]initWithArray:oldCachedRepresentatives];
            }
        }
    }
    else {
        if ([representativeType isEqualToString:@"cachedCongresspersons"]) {
            [RepManager sharedInstance].listOfCongressmen = [[NSMutableArray alloc]init];
        }
        else {
            [RepManager sharedInstance].listofStateLegislators = [[NSMutableArray alloc]init];
        }
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [[LocationService sharedInstance]startUpdatingLocation];
        }
    }
}
@end