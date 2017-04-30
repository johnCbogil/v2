//
//  FirebaseManager.h
//  Voices
//
//  Created by Daniel Nomura on 3/1/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"
#import "Action.h"

@interface FirebaseManager : NSObject
+(FirebaseManager *) sharedInstance;

//Group methods
- (void)followGroup:(NSString *)groupKey withCompletion:(void(^)(BOOL result))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)fetchFollowedGroupsForCurrentUserWithCompletion:(void(^)(NSArray *listOfFollowedGroups))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)fetchAllGroupsWithCompletion:(void(^)(NSArray *groups))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)removeGroup:(Group *)group;
- (void)fetchGroupWithKey:(NSString *)groupKey withCompletion:(void(^)(Group *group))successBlock onError:(void(^)(NSError *error))errorBlock;

//Action methods
//- (void)fetchActionsWithCompletion:(void(^)(NSArray *listOfActions))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)fetchActionsForGroup:(Group*) group withCompletion:(void(^)(NSArray *listOfActions))successBlock;

//Policy Positions
- (void)fetchPolicyPositionsForGroup:(Group *)group withCompletion:(void(^)(NSArray *positions))successBlock onError:(void(^)(NSError *error))errorBlock;


@end
