
//  CacheManager.m
//  Voices
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
    }
    return self;
}

- (NSArray *)fetchRepsFromCache:(NSString *)representativeType {
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingCachedRepresentatives = [currentDefaults objectForKey:representativeType];
    if (dataRepresentingCachedRepresentatives != nil) {
        NSArray *oldCachedRepresentatives = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingCachedRepresentatives];
        if (oldCachedRepresentatives != nil){
            return oldCachedRepresentatives;
        }
    }
    return nil;
}

- (void)saveRepsToCache:(NSArray *)representatives forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:representatives] forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
@end