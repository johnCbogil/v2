//
//  FirebaseManager.m
//  Voices
//
//  Created by Daniel Nomura on 3/1/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "FirebaseManager.h"
@interface FirebaseManager()
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


#pragma mark - Action

@end
