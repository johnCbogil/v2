//
//  FirebaseManager.h
//  Voices
//
//  Created by Daniel Nomura on 3/1/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;

@interface FirebaseManager : NSObject
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *actionsRef;
@property (strong, nonatomic) FIRDatabaseReference *currentUserRef;
@property (strong, nonatomic) FIRDatabaseReference *currentUsersGroupsRef;
@property (strong, nonatomic) NSString *userID;
+(FirebaseManager *) sharedInstance;
@end
