//
//  CacheManager.m
//  v2
//
//  Created by John Bogil on 9/9/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "CacheManager.h"
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
    NSLog(@"Retrieving from cache");
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(firstName = %@ && lastName = %@)",firstName, lastName];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *cachedObjects = [self.context executeFetchRequest:request
                                                         error:&error];
    if (cachedObjects.count) {
        return cachedObjects[0];
    }
    else {
        return nil;
    }
}
@end
