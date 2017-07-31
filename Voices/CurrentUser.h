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
@property (strong, nonatomic) NSMutableArray *listOfFollowedGroups;
@property (strong, nonatomic) NSMutableArray *listOfActions;
@property (strong, nonatomic) NSString *firebaseUserID;

@end
