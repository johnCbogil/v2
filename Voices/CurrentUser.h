//
//  CurrentUser.h
//  Voices
//
//  Created by Bogil, John on 9/1/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"

@interface CurrentUser : NSObject

+ (CurrentUser *) sharedInstance;
- (void)followGroup:(NSString *)groupKey WithCompletion:(void(^)(BOOL result))successBlock onError:(void(^)(NSError *error))errorBlock;
- (void)fetchFollowedGroupsForUserID:(NSString *)userID WithCompletion:(void(^)(NSArray *listOfFollowedGroups))successBlock onError:(void(^)(NSError *error))errorBlock;
@end
