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
@property (strong, nonatomic) NSString *userID;
+(FirebaseManager *) sharedInstance;
- (void)followGroup:(NSString *)groupKey WithCompletion:(void(^)(BOOL result))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)fetchFollowedGroupsForUserID:(NSString *)userID WithCompletion:(void(^)(NSArray *listOfFollowedGroups))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)removeGroup:(Group *)group;
- (void)fetchActionsWithCompletion:(void(^)(NSArray *listOfActions))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)fetchActionsForGroup:(Group*) group withCompletion:(void(^)(NSArray *listOfActions))successBlock;

@end
