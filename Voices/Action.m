//
//  Action.m
//  Voices
//
//  Created by David Weissler on 6/6/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "Action.h"

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
    _debug = [dictionary[@"debug"]intValue];
    return self;
}

@end

NS_ASSUME_NONNULL_END
