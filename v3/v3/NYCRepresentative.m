//
//  NYCRepresentative.m
//  Voices
//
//  Created by John Bogil on 1/23/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NYCRepresentative.h"

@implementation NYCRepresentative

- (id)initWithData:(NSArray*)data {
    NSLog(@"%@", data);
    self = [super init];
    if (self != nil) {
        self.name = [data valueForKey:@"name"];
        self.address = [data valueForKey:@"address"];
        self.email = [data valueForKey:@"emails"];
        self.party = [data valueForKey:@"party"];
        self.photoURL = [NSURL URLWithString:[data valueForKey:@"photoUrl"]];
        self.phone = [data valueForKey:@"phones"][0];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.phone = [decoder decodeObjectForKey:@"phones"];
        self.party = [decoder decodeObjectForKey:@"party"];
        self.email = [decoder decodeObjectForKey:@"emails"];
        self.photoURL = [decoder decodeObjectForKey:@"photoUrl"];
        self.address = [decoder decodeObjectForKey:@"address"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.phone forKey:@"phones"];
    [coder encodeObject:self.party forKey:@"party"];
    [coder encodeObject:self.email forKey:@"emails"];
    [coder encodeObject:self.photoURL forKey:@"photoUrl"];
    [coder encodeObject:self.address forKey:@"address"];
}
@end