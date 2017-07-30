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
#import "PolicyPosition.h"

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

+ (FirebaseManager *) sharedInstance {
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
    
    [CurrentUser sharedInstance].firebaseUserID = [FIRAuth auth].currentUser.uid;
    self.currentUserRef = [self.usersRef child:[CurrentUser sharedInstance].firebaseUserID];
    self.currentUsersGroupsRef = [self.currentUserRef child:@"groups"];
}

- (void)createUser {
    
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
        if (error) {
            return;
        }
        
        [self createUserReferences];
        
        // Add user to list of users
        [self.usersRef updateChildValues:@{[CurrentUser sharedInstance].firebaseUserID : @{@"userID" : [CurrentUser sharedInstance].firebaseUserID}} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error) {
                return;
            }
        }];
    }];
}


#pragma mark - Group
- (void)followGroup:(NSString *)groupKey withCompletion:(void(^)(BOOL result))successBlock onError:(void(^)(NSError *error))errorBlock {
    
    FIRDatabaseReference *currentUserRef = [[[self.usersRef child:[FIRAuth auth].currentUser.uid]child:@"groups"]child:groupKey];
    
    // Check if the current user already belongs to selected group or not
    [currentUserRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        BOOL isUserFollowingGroup = snapshot.value == [NSNull null] ? NO : YES;
        
        if (snapshot.value == [NSNull null]) {
            
            // Add group to user's groups
            [[[self.usersRef child:[FIRAuth auth].currentUser.uid]child:@"groups"] updateChildValues:@{groupKey :@1} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if (error) {
                }
            }];
            
            // Add user to group's users
            [[[self.groupsRef child:groupKey]child:@"followers"] updateChildValues:@{[FIRAuth auth].currentUser.uid :@1} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            }];
            
            // Add group to user's subscriptions
            NSString *topic = [groupKey stringByReplacingOccurrencesOfString:@" " withString:@""];
            [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
            
            isUserFollowingGroup = NO;
            
            [[ReportingManager sharedInstance]reportEvent:kSUBSCRIBE_EVENT eventFocus:groupKey eventData:[FIRAuth auth].currentUser.uid];
            
            successBlock(isUserFollowingGroup);
        }
        else {
            
            isUserFollowingGroup = YES;
            successBlock(isUserFollowingGroup);
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        
    }];
}

- (void)fetchAllGroupsWithCompletion:(void (^)(NSArray *))successBlock onError:(void (^)(NSError *))errorBlock {
    
    [self.groupsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *groups = snapshot.value;
        NSMutableArray *groupsArray = [NSMutableArray array];
        [groups enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            if (![obj isKindOfClass:[NSDictionary class]]) {
                return ;
            }
            
            Group *group = [[Group alloc] initWithKey:key groupDictionary:obj];
            
            BOOL debug = [self isInDebugMode];
            // if app is in debug, add all groups
            if (debug) {
                [groupsArray addObject:group];
            }
            // if app is not in debug, add only non-debug groups
            else if (!group.debug) {
                [groupsArray addObject:group];
            }
        }];
        successBlock(groupsArray);
    } withCancelBlock:^(NSError * _Nonnull error) {
        errorBlock(error);
    }];
}

- (void)resubscribeToTopicsOnReInstall {
    
    for (Group *group in [CurrentUser sharedInstance].listOfFollowedGroups) {
        
        NSString *topic = [group.key stringByReplacingOccurrencesOfString:@" " withString:@""];
        [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
    }
}

- (void) fetchFollowedGroupsForCurrentUserWithCompletion:(void (^)(NSArray *))successBlock onError:(void (^)(NSError *))errorBlock {
    
    [CurrentUser sharedInstance].listOfFollowedGroups = [NSMutableArray array];
    
    // For each group that the user belongs to
    [[[self.usersRef child:[FIRAuth auth].currentUser.uid] child:@"groups"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // This is happening once per group
        if ([snapshot.value isKindOfClass:[NSNull class]]) {
            successBlock(nil);
            return;
        }
        NSDictionary *groupsKeysDict = snapshot.value;
        NSArray *groupKeys = groupsKeysDict.allKeys;
        
        for (NSString *key in groupKeys) {
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

                [self fetchActionsForGroup:group withCompletion:^(NSArray *listOfActions) {
                    successBlock(listOfActions);
                }];
            }];
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        
    }];
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
    
    // Remove associated actions
    NSMutableArray *discardedActions = [NSMutableArray array];
    for (Action *action in [CurrentUser sharedInstance].listOfActions) {
        if(action.groupKey != nil && group.key != nil) {
            if([action.groupKey caseInsensitiveCompare: group.key] == NSOrderedSame){
                [discardedActions addObject:action];
            }
        }
    }
    [[CurrentUser sharedInstance].listOfActions removeObjectsInArray:discardedActions];
    
    [[ReportingManager sharedInstance]reportEvent:kUNSUBSCRIBE_EVENT eventFocus:group.key eventData:[FIRAuth auth].currentUser.uid];
    
}

- (void)fetchGroupWithKey:(NSString *)groupKey withCompletion:(void (^)(Group *))successBlock onError:(void (^)(NSError *))errorBlock {
    [[[[self.usersRef child:[FIRAuth auth].currentUser.uid] child:@"groups"]child: groupKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        Group *group;
        if (snapshot.value != [NSNull null]) {
            group = [[Group alloc] initWithKey:groupKey groupDictionary:snapshot.value];
            
        }
        successBlock(group);
    } withCancelBlock:^(NSError * _Nonnull error) {
        errorBlock(error);
    }];
}

#pragma mark - Actions

- (void)actionCompleteButtonPressed:(Action *)action withCompletion:(void(^)(id))successBlock onError:(void (^)(NSError *))errorBlock {
    
    FIRDatabaseReference *currentUserRef = [[self.usersRef child:[FIRAuth auth].currentUser.uid]child:@"actionsCompleted"];
    
    [[currentUserRef child:action.key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        BOOL isActionCompleted = snapshot.value == [NSNull null] ? NO : YES;

        if (!isActionCompleted) {
            
            [currentUserRef updateChildValues:@{action.key : @1}];
        }
        else {
            [[currentUserRef child:action.key]removeValue];
        }
        successBlock;
    }];
}

// TODO: THIS IS BEING CALLED WHEN 'MY GROUPS' TAB IS SELECTED AND PROBABLY SHOULDNT NEED TO BE?
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
            
            if ([self shouldAddActionToList:action]) {
                [[CurrentUser sharedInstance].listOfActions addObject:action];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                [CurrentUser sharedInstance].listOfActions = [[CurrentUser sharedInstance].listOfActions sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
                successBlock([CurrentUser sharedInstance].listOfActions);
                [actions addObject:action];
            }
            dispatch_group_leave(actionsGroup);
        }];
    }
    dispatch_group_notify(actionsGroup, dispatch_get_main_queue(), ^{
        successBlock(actions);
    });
}

- (void)fetchListOfCompletedActionsWithCompletion:(void(^)(NSArray *listOfCompletedActions))successBlock onError:(void(^)(NSError *error))errorBlock {
    
    [[self.currentUserRef child:@"actionsCompleted"]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.value != [NSNull null]) {
            
            NSDictionary *actionKeysDict = snapshot.value;
            NSArray *actionKeys = actionKeysDict.allKeys;
            successBlock(actionKeys);
        }
    }];
}

#pragma mark - Policy Positions
- (void) fetchPolicyPositionsForGroup:(Group *)group withCompletion:(void (^)(NSArray *))successBlock onError:(void (^)(NSError *))errorBlock {
    
    if (group.key.length) {
        
        FIRDatabaseReference *policyPositionsRef = [[self.groupsRef child:group.key]child:@"policyPositions"];
        [policyPositionsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if ([snapshot exists] && [snapshot hasChildren]) {
                NSDictionary *policyPositionsDict = snapshot.value;
                NSMutableArray *policyPositionsArray = [NSMutableArray array];
                [policyPositionsDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    PolicyPosition *policyPosition = [[PolicyPosition alloc]initWithKey:key policyPosition:obj];
                    [policyPositionsArray addObject:policyPosition];
                }];
                successBlock(policyPositionsArray);
            }
        } withCancelBlock:^(NSError * _Nonnull error) {
            errorBlock(error);
        }];
    }
}

- (BOOL)shouldAddActionToList:(Action *)action {
    
    NSDate *currentTime = [NSDate date];
    
    if (action.timestamp < currentTime.timeIntervalSince1970) {

        NSInteger index = [[CurrentUser sharedInstance].listOfActions indexOfObjectPassingTest:^BOOL(Action *actionInArray, NSUInteger idx, BOOL *stop) {
            if ([action.key isEqualToString:actionInArray.key]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if (index != NSNotFound) {
            // We already have this action in our table
            return NO;
        }
        
        BOOL debug = [self isInDebugMode];
        // if app is in debug, add all groups
        if (debug) {
            return YES;
        }
        // if app is not in debug, add only non-debug groups
        else if (!action.debug) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Private methods

- (BOOL)isInDebugMode {
#if DEBUG
    return YES;
#else
    return NO;
#endif
}

@end
