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
            [self fetchFollowedGroups];
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

- (void)fetchFollowedGroups {
    
    [self.currentUsersGroupsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {

        if (snapshot.exists) {
            NSLog(@"GROUPS: %@", snapshot);
            NSDictionary *groupKeysDict = snapshot.value;
            NSArray *groupKeysArray = groupKeysDict.allKeys;
            
            for (NSString *key in groupKeysArray) {
                // fetch group data for key
                [self fetchGroupForKey:key];
            }
        }
        
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)fetchGroupForKey:(NSString *)key {
    
    [[self.groupsRef child:key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {

        if (snapshot.exists) {
            NSLog(@"GROUP DATA: %@", snapshot);
            Group *group = [[Group alloc]initWithKey:key groupDictionary:snapshot.value];
            [self.listOfFollowedGroups addObject:group];
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
    
}
@end
