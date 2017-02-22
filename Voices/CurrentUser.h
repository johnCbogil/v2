//
//  CurrentUser.h
//  Voices
//
//  Created by Bogil, John on 9/1/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"
#import "Action.h"

@interface CurrentUser : NSObject

+ (CurrentUser *) sharedInstance;
- (void)followGroup:(NSString *)groupKey WithCompletion:(void(^)(BOOL result))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)fetchFollowedGroupsForUserID:(NSString *)userID WithCompletion:(void(^)(NSArray *listOfFollowedGroups))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)fetchActionsWithCompletion:(void(^)(NSArray *listOfActions))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)fetchActionsForGroup:(Group*) group withCompletion:(void(^)(NSArray *listOfActions))successBlock;
- (void)removeGroup:(Group *)group;
- (Group *)findGroupByAction:(Action *)action;
@property (strong, nonatomic) NSMutableArray *listOfFollowedGroups;
@property (strong, nonatomic) NSMutableArray *listOfActions;
@property (strong, nonatomic) NSString *userID;

@end
