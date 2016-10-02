//
//  CurrentUser.m
//  Voices
//
//  Created by Bogil, John on 9/1/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "CurrentUser.h"
#import "Action.h"

@import Firebase;

@interface CurrentUser()

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSMutableArray <Action *> *listOfActions;
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *actionsRef;
@property (strong, nonatomic) FIRDatabaseReference *currentUserRef;
@property (strong, nonatomic) FIRDatabaseReference *currentUsersGroupsRef;

@end

@implementation CurrentUser

// TODO: THIS CLASS SHOULD BE SEPARATED BETWEEN USER MODEL AND NETWORK MANAGER

+ (CurrentUser *) sharedInstance {
    static CurrentUser *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        
        self.listOfFollowedGroups = @[].mutableCopy;
        
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
    self.currentUserRef = [self.usersRef child:[FIRAuth auth].currentUser.uid];
    self.currentUsersGroupsRef = [self.currentUserRef child:@"groups"];
}

- (void)createUser {
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
        if (error) {
            NSLog(@"UserAuth error: %@", error);
//            self.isUserAuthInProgress = NO;
            return;
        }
        
        self.userID = [FIRAuth auth].currentUser.uid;
        
        [self createUserReferences];
        
        NSLog(@"Created a new userID: %@", self.userID);
        
        // Add user to list of users
        [self.usersRef updateChildValues:@{self.userID : @{@"userID" : self.userID}} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error) {
                NSLog(@"Error adding user to database: %@", error);
//                self.isUserAuthInProgress = NO;
                return;
            }
            NSLog(@"Created user %@ in database", self.userID);
        }];
    }];
}

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
                    //                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:group.name message:@"You will now receive updates from this group" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
                    //                    [alert show];
                    NSLog(@"Added user to group via deeplink succesfully");
                }
            }];
            
            // Add group to user's subscriptions
            NSString *topic = [groupKey stringByReplacingOccurrencesOfString:@" " withString:@""];
            [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
            NSLog(@"User subscribed to %@", groupKey);
            
            isUserFollowingGroup = NO;
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
 
//    self.isUserAuthInProgress = NO;
    
//    [self toggleActivityIndicatorOn];
//    __weak GroupsViewController *weakSelf = self;
    NSMutableArray *groupsArray = [NSMutableArray array];
    
    // For each group that the user belongs to
    [[[self.usersRef child:[FIRAuth auth].currentUser.uid] child:@"groups"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // This is happening once per group
        if ([snapshot.value isKindOfClass:[NSNull class]]) {
//            [weakSelf toggleActivityIndicatorOff];
            return;
        }
        // Retrieve this group's key
        
        NSDictionary *groupsKeys = snapshot.value;
        NSArray *keys = groupsKeys.allKeys;

        for (NSString *key in keys) {
            // Go to the groups table
//            [weakSelf fetchGroupWithKey:key groupsArray:groupsArray];
            
            [[self.groupsRef child:key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                if (snapshot.value == [NSNull null]) { // Why is this different than NSNull class check above?
//                    [self toggleActivityIndicatorOff];
                    return;
                }
                // Iterate through the listOfFollowedGroups and determine the index of the object that passes the following test:
                NSInteger index = [self.listOfFollowedGroups indexOfObjectPassingTest:^BOOL(Group *group, NSUInteger idx, BOOL *stop) {
                    if ([group.key isEqualToString:key]) {
                        *stop = YES;
                        return YES;
                    }
                    return NO;
                    
                }];
                if (index != NSNotFound) {
                    // We already have this group in our table
//                    [self toggleActivityIndicatorOff];
                    return;
                }
                
                Group *group = [[Group alloc] initWithKey:key groupDictionary:snapshot.value];
                
                [groupsArray addObject:group];
                successBlock(groupsArray);
                
//                self.listOfFollowedGroups = groupsArray;
//                [self.tableView reloadData];
                
                // Retrieve the actions for this group
                if(!snapshot.value[@"actions"]) {
                    return;
                }
//                NSArray *actionKeys = [snapshot.value[@"actions"] allKeys];
//                for (NSString *actionKey in actionKeys) {
//                    [self fetchActionsForActionKey:actionKey];
//                }
            }];

        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
}




@end
