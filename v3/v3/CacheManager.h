//
//  CacheManager.h
//  v3
//
//  Created by John Bogil on 9/9/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "FederalRepresentative.h"
#import <CoreData/CoreData.h>

@interface CacheManager : NSObject

+(CacheManager *) sharedInstance;
- (id)fetchRepPhotoWithEntityName:(NSString*)entityName withFirstName:(NSString*)firstName withLastName:(NSString*)lastName;
- (void)cacheRepresentativePhoto:(id)representative withEntityName:(NSString*)entityName;
- (NSArray *)checkUserDefaultsForRepresentative:(NSString*)representativeType;

@end