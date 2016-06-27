//
//  Group.m
//  Voices
//
//  Created by Bogil, John on 5/27/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "Group.h"

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
    
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
