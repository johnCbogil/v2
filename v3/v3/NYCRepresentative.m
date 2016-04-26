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
    //    NSLog(@"%@", data);
    self = [super init];
    if (self != nil) {
        self.districtNumber = [(NSNumber*)data[0] stringValue];
        self.firstName = data[1];
        self.lastName = data[2];
        self.phone = data[3];
        self.email = data[4];
        self.party = data[5];
        self.photoURL = [NSURL URLWithString:data[6]];
        self.twitter = data[7];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.districtNumber = [decoder decodeObjectForKey:@"districtNumber"];
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.party = [decoder decodeObjectForKey:@"party"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.photoURL = [decoder decodeObjectForKey:@"photoURL"];
        self.photo = [decoder decodeObjectForKey:@"photo"];
        self.twitter = [decoder decodeObjectForKey:@"twitter"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.districtNumber forKey:@"districtNumber"];
    [coder encodeObject:self.firstName forKey:@"firstName"];
    [coder encodeObject:self.lastName forKey:@"lastName"];
    [coder encodeObject:self.party forKey:@"party"];
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:self.photoURL forKey:@"photoURL"];
    [coder encodeObject:self.photo forKey:@"photo"];
    [coder encodeObject:self.twitter forKey:@"twitter"];
}
@end