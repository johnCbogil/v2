//
//  FirebaseManager.m
//  Voices
//
//  Created by Daniel Nomura on 3/1/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "FirebaseManager.h"
#import "CurrentUser.h"
#import "ReportingManager.h"

@import Firebase;

@interface FirebaseManager()
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *actionsRef;
@property (strong, nonatomic) FIRDatabaseReference *currentUserRef;
@property (strong, nonatomic) FIRDatabaseReference *currentUsersGroupsRef;
@property (strong, nonatomic) NSMutableArray *actionKeys;

@end

@implementation FirebaseManager

#pragma mark - Initialization
+(FirebaseManager *) sharedInstance {
    static FirebaseManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;

}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.actionKeys = @[].mutableCopy;
        
        [self createInitialReferences];
        if ([FIRAuth auth].currentUser.uid) {
            [self createUserReferences];
        }
        else {
            [self createUser];
        }
    }
    return self;
}
- (void)createInitialReferences {
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    self.actionsRef = [self.rootRef child:@"actions"];
}

- (void)createUserReferences {
    self.userID = [FIRAuth auth].currentUser.uid;
    self.currentUserRef = [self.usersRef child:self.userID];
    self.currentUsersGroupsRef = [self.currentUserRef child:@"groups"];
}

- (void)createUser {
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
        if (error) {
            NSLog(@"UserAuth error: %@", error);
            return;
        }
        
        [self createUserReferences];
        
        NSLog(@"Created a new userID: %@", self.userID);
        
        // Add user to list of users
        [self.usersRef updateChildValues:@{self.userID : @{@"userID" : self.userID}} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error) {
                NSLog(@"Error adding user to database: %@", error);
                return;
            }
            NSLog(@"Created user %@ in database", self.userID);
        }];
    }];
}


#pragma mark - Group
- (void)followGroup:(NSString *)groupKey WithCompletion:(void(^)(BOOL result))successBlock onError:(void(^)(NSError *error))errorBlock {
    
    FIRDatabaseReference *currentUserRef = [[[self.usersRef child:[FIRAuth auth].currentUser.uid]child:@"groups"]child:groupKey];
    
    // Check if the current user already belongs to selected group or not
    [currentUserRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        BOOL isUserFollowingGroup = snapshot.value == [NSNull null] ? NO : YES;
        
        NSLog(@"User %d a member of selected group", isUserFollowingGroup);
        
        if (snapshot.value == [NSNull null]) {
            
            // Add group to user's groups
            [[[self.usersRef child:[FIRAuth auth].currentUser.uid]child:@"groups"] updateChildValues:@{groupKey :@1} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if (error) {
                    NSLog(@"write error: %@", error);
                }
            }];
            
            // Add user to group's users
            [[[self.groupsRef child:groupKey]child:@"followers"] updateChildValues:@{[FIRAuth auth].currentUser.uid :@1} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if (error) {
                    NSLog(@"write error: %@", error);
                }
                else {
                    NSLog(@"Added user to group via deeplink succesfully");
                }
            }];
            
            // Add group to user's subscriptions
            NSString *topic = [groupKey stringByReplacingOccurrencesOfString:@" " withString:@""];
            [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
            NSLog(@"User subscribed to %@", groupKey);
            
            isUserFollowingGroup = NO;
            
            [[ReportingManager sharedInstance]reportEvent:kSUBSCRIBE_EVENT eventFocus:groupKey eventData:[FIRAuth auth].currentUser.uid];
            
            successBlock(isUserFollowingGroup);
        }
        else {
            
            isUserFollowingGroup = YES;
            successBlock(isUserFollowingGroup);
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)fetchFollowedGroupsForUserID:(NSString *)userID WithCompletion:(void(^)(NSArray *listOfFollowedGroups))successBlock onError:(void(^)(NSError *error))errorBlock {
    
    [CurrentUser sharedInstance].listOfFollowedGroups = [NSMutableArray array];
    
    // For each group that the user belongs to
    [[[self.usersRef child:[FIRAuth auth].currentUser.uid] child:@"groups"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // This is happening once per group
        if ([snapshot.value isKindOfClass:[NSNull class]]) {
            successBlock(nil);
            return;
        }
        NSDictionary *groupsKeys = snapshot.value;
        NSArray *keys = groupsKeys.allKeys;
        
        for (NSString *key in keys) {
            // Go to the groups table
            [[self.groupsRef child:key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                if (snapshot.value == [NSNull null]) { // Why is this different than NSNull class check above?
                    return;
                }
                // Iterate through the listOfFollowedGroups and determine the index of the object that passes the following test:
                NSInteger index = [[CurrentUser sharedInstance].listOfFollowedGroups indexOfObjectPassingTest:^BOOL(Group *group, NSUInteger idx, BOOL *stop) {
                    if ([group.key isEqualToString:key]) {
                        *stop = YES;
                        return YES;
                    }
                    return NO;
                    
                }];
                if (index != NSNotFound) {
                    // We already have this group in our table
                    return;
                }
                
                Group *group = [[Group alloc] initWithKey:key groupDictionary:snapshot.value];
                
                BOOL debug = [self isInDebugMode];
                // if app is in debug, add all groups
                if (debug) {
                    [[CurrentUser sharedInstance].listOfFollowedGroups addObject:group];
                }
                // if app is not in debug, add only non-debug groups
                else if (!group.debug) {
                    [[CurrentUser sharedInstance].listOfFollowedGroups addObject:group];
                }
                
                // Retrieve the actions for this group
                if(!snapshot.value[@"actions"]) {
                    successBlock(nil);
                    return;
                }
                self.actionKeys = [snapshot.value[@"actions"] allKeys].mutableCopy;
                [self fetchActionsWithCompletion:^(NSArray *listOfActions) {
                    self.actionKeys = @[].mutableCopy;
                    successBlock(listOfActions);
                } onError:^(NSError *error) {
                    
                }];
            }];
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)fetchActionsWithCompletion:(void(^)(NSArray *listOfActions))successBlock onError:(void(^)(NSError *error))errorBlock {
    
    for (NSString *actionKey in self.actionKeys) {
        [[self.actionsRef child:actionKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.value == [NSNull null]) {
                return;
            }
            
            // Check to see if the action key is in the listOfActions
            NSInteger index = [[CurrentUser sharedInstance].listOfActions indexOfObjectPassingTest:^BOOL(Action *action, NSUInteger idx, BOOL *stop) {
                if ([action.key isEqualToString:actionKey]) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            }];
            if (index != NSNotFound) {
                // We already have this action in our table
                return;
            }
            NSLog(@"%@", snapshot.value);
            Action *newAction = [[Action alloc] initWithKey:actionKey actionDictionary:snapshot.value];
            
            NSDate *currentTime = [NSDate date];
            NSDate *newDate = [currentTime dateByAddingTimeInterval:-3600*5]; // We are subtracting 5 hours bc UTC is 5 hours ahead of EST
            
            if(newAction.timestamp < newDate.timeIntervalSince1970) {
                
                BOOL debug = [self isInDebugMode];
                // if app is in debug, add all groups
                if (debug) {
                    [[CurrentUser sharedInstance].listOfActions addObject:newAction];
                }
                // if app is not in debug, add only non-debug groups
                else if (!newAction.debug) {
                    [[CurrentUser sharedInstance].listOfActions addObject:newAction];
                }
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                [CurrentUser sharedInstance].listOfActions = [[CurrentUser sharedInstance].listOfActions sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
                successBlock([CurrentUser sharedInstance].listOfActions);
            }
        }];
        
    }
    successBlock([CurrentUser sharedInstance].listOfActions);
}

- (void)fetchActionsForGroup:(Group*) group withCompletion:(void(^)(NSArray *listOfActions))successBlock {
    //Need dispatch group to wait for all action keys calls to finish
    dispatch_group_t actionsGroup = dispatch_group_create();
    NSMutableArray *actions = [NSMutableArray array];
    for (NSString *actionKey in group.actionKeys) {
        dispatch_group_enter(actionsGroup);
        [[self.actionsRef child:actionKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.value == [NSNull null]) {
                dispatch_group_leave(actionsGroup);
                return;
            }
            Action *action = [[Action alloc] initWithKey:actionKey actionDictionary:snapshot.value];
            [actions addObject:action];
            dispatch_group_leave(actionsGroup);
        }];
    }
    dispatch_group_notify(actionsGroup, dispatch_get_main_queue(), ^{
        successBlock(actions);
    });
}

- (void)removeGroup:(Group *)group {
    
    // Remove group from local array
    [[CurrentUser sharedInstance].listOfFollowedGroups removeObject:group];
    NSMutableArray *discardedGroups = [NSMutableArray array];
    for (Group *g in [CurrentUser sharedInstance].listOfFollowedGroups) {
        if ([g.key isEqualToString:group.key]) {
            [discardedGroups addObject:g];
        }
    }
    [[CurrentUser sharedInstance].listOfFollowedGroups removeObjectsInArray:discardedGroups];
    
    // Remove group from user's groups
    [[[[self.usersRef child:[FIRAuth auth].currentUser.uid]child:@"groups"]child:group.key]removeValue];
    
    // Remove user from group's users
    [[[[self.groupsRef child:group.key]child:@"followers"]child:[FIRAuth auth].currentUser.uid]removeValue];
    
    // Remove group from user's subscriptions
    [[FIRMessaging messaging]unsubscribeFromTopic:[NSString stringWithFormat:@"/topics/%@",group.key]];
    NSLog(@"User unsubscribed to %@", group.key);
    
    // Remove associated actions
    NSMutableArray *discardedActions = [NSMutableArray array];
    for (Action *action in [CurrentUser sharedInstance].listOfActions) {
        if ([action.groupKey isEqualToString:group.key]) {
            [discardedActions addObject:action];
        }
    }
    [[CurrentUser sharedInstance].listOfActions removeObjectsInArray:discardedActions];
    
    [[ReportingManager sharedInstance]reportEvent:kUNSUBSCRIBE_EVENT eventFocus:group.key eventData:[FIRAuth auth].currentUser.uid];
    
}


- (BOOL)isInDebugMode {
#if DEBUG
    return YES;
#else
    return NO;
#endif
}

#pragma mark - Action

@end
