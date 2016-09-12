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

- (void)followGroup:(NSString *)groupKey {
    
    // Check if the current user already belongs to selected group or not
    FIRDatabaseReference *currentUserRef = [[[self.usersRef child:[FIRAuth auth].currentUser.uid]child:@"groups"]child:groupKey];
    [currentUserRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *result = snapshot.value == [NSNull null] ? @"is not" : @"is";
        NSLog(@"User %@ a member of selected group", result);
        if (snapshot.value == [NSNull null]) {
            
            // Add group to user's groups
            [[[self.usersRef child:self.userID]child:@"groups"] updateChildValues:@{groupKey :@1} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if (error) {
                    NSLog(@"write error: %@", error);
                }
            }];
            
            // Add user to group's users
            [[[self.groupsRef child:groupKey]child:@"followers"] updateChildValues:@{self.userID :@1} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
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
        }
//        else {
//            
//            
//            UIAlertController *alert = [UIAlertController
//                                        alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
//                                        message:@"Would you like to stop helping this group?"
//                                        preferredStyle:UIAlertControllerStyleActionSheet];
//            
//            UIAlertAction *button0 = [UIAlertAction
//                                      actionWithTitle:@"Cancel"
//                                      style:UIAlertActionStyleCancel
//                                      handler:^(UIAlertAction * action)
//                                      {}];
//            
//            UIAlertAction *button1 = [UIAlertAction
//                                      actionWithTitle:@"Unfollow"
//                                      style:UIAlertActionStyleDestructive
//                                      handler:^(UIAlertAction * action) {
//                                          // Remove group
//                                          [[NSNotificationCenter defaultCenter]postNotificationName:@"removeGroup" object:group];
//                                          
//                                          // read the value once to see if group key exists
//                                          [[[[self.usersRef child:self.userID] child:@"groups"]child:self.group.key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//                                              if (snapshot.value == [NSNull null]) {
//                                                  
//                                                  [self.followGroupButton setTitle:@"Follow This Group" forState:UIControlStateNormal];
//                                                  
//                                              }
//                                          } withCancelBlock:^(NSError * _Nonnull error) {
//                                              NSLog(@"%@", error.localizedDescription);
//                                          }];
//                                      }];
//            
//            [alert addAction:button0];
//            [alert addAction:button1];
//            [self presentViewController:alert animated:YES completion:nil];
//        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}


@end
