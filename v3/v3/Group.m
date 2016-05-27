//
//  Group.m
//  Voices
//
//  Created by Bogil, John on 5/27/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "Group.h"

@implementation Group

- (id)initWithKey:(NSString *)key andValue:(NSDictionary *)value {
    
    self.name = [value valueForKey:@"name"];
    self.key = key;
    
    return self;
}

@end
