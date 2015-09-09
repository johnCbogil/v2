//
//  CacheManager.h
//  v2
//
//  Created by John Bogil on 9/9/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Congressperson.h"
#import <CoreData/CoreData.h>

@interface CacheManager : NSObject
+(CacheManager *) sharedInstance;
- (id)fetchRepWithEntityName:(NSString*)entityName withFirstName:(NSString*)firstName withLastName:(NSString*)lastName;
@property (strong, nonatomic) Congressperson *congressperson;
@end
