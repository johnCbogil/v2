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
    _group = dictionary[@"group"];
    _title = dictionary[@"title"];
    return self;
}

@end

NS_ASSUME_NONNULL_END
