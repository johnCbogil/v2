//
//  Action.m
//  Voices
//
//  Created by David Weissler on 6/6/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "Action.h"
#import "FirebaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@implementation Action

- (instancetype)initWithKey:(NSString *)key actionDictionary:(NSDictionary *)dictionary {
    self = [self init];
    _key = key;
    _body = dictionary[@"body"];
    _groupName = dictionary[@"groupName"];
    _groupKey = dictionary[@"groupKey"];
    _title = dictionary[@"title"];
    _groupImageURL = [NSURL URLWithString:dictionary[@"imageURL"]];
    _subject = dictionary[@"subject"];
    _timestamp = [dictionary[@"timestamp"]intValue];
    _level = [dictionary[@"level"]intValue];
    _script = dictionary[@"script"];
    if (!_script.length) {
        _script = kGenericScript;
    }
    _debug = [dictionary[@"debug"]intValue];
    
    [[FirebaseManager sharedInstance]fetchListOfCompletedActionsWithCompletion:^(NSArray *listOfCompletedActions) {
        if ([listOfCompletedActions containsObject:_key]) {
            _isCompleted = YES;
        }
        else {
            _isCompleted = NO;
        }
    } onError:^(NSError *error) {
        
    }];
    return self;
}

@end

NS_ASSUME_NONNULL_END
