//
//  Group.m
//  Voices
//
//  Created by Bogil, John on 5/27/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "Group.h"
#import "CurrentUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface Group()

@end

@implementation Group

- (instancetype)initWithKey:(NSString *)key groupDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.name = dictionary[@"name"];
    self.groupType = dictionary[@"groupType"];
    self.key = key;
    self.groupImageURL = [NSURL URLWithString:dictionary[@"imageURL"]];
    self.groupDescription = dictionary[@"description"];
    self.debug = [dictionary[@"debug"]intValue];
    self.actionKeys = [dictionary[@"actions"] allKeys];
    return self;
}

// TODO: THERE IS PROBABLY A BETTER WAY TO RETURN GROUP IMAGE FOR ACTIONS
+ (Group *)groupForAction:(Action *)action {
    // When in Action Table View section, group and userID is needed to push to Group page if user presses the Group logo imageView - if either condition match return group
    Group *group;
    for (Group *currentGroup in [CurrentUser sharedInstance].listOfFollowedGroups) {
        if([currentGroup.name isEqualToString:action.groupName]||[currentGroup.key isEqualToString:action.groupKey]){
            group = currentGroup;
            
            //TODO: Break here??
        }
    }
    return group;

}

@end

NS_ASSUME_NONNULL_END
