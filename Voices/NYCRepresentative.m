//
//  NYCRepresentative.m
//  Voices
//
//  Created by John Bogil on 1/23/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NYCRepresentative.h"

@implementation NYCRepresentative

- (id)initWithData:(NSDictionary*)data {
    //    NSLog(@"%@", data);
    self = [super init];
    if (self != nil) {
        self.districtNumber = data[@"district"];
        self.firstName = data[@"firstName"];
        self.lastName = data[@"lastName"];
        self.phone = data[@"phoneNumber"];
        self.email = data[@"email"];
        self.party = data[@"party"];
        self.photoURL = [NSURL URLWithString:data[@"photoURLPath"]];
        self.twitter = data[@"twitter"];
        self.gender = data[@"gender"];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.districtNumber = [decoder decodeObjectForKey:@"districtNumber"];
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.phone = [decoder decodeObjectForKey:@"phoneNumber"];
        self.party = [decoder decodeObjectForKey:@"party"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.photoURL = [decoder decodeObjectForKey:@"photoURL"];
        self.photo = [decoder decodeObjectForKey:@"photo"];
        self.twitter = [decoder decodeObjectForKey:@"twitter"];
        self.gender = [decoder decodeObjectForKey:@"gender"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.districtNumber forKey:@"districtNumber"];
    [coder encodeObject:self.firstName forKey:@"firstName"];
    [coder encodeObject:self.lastName forKey:@"lastName"];
    [coder encodeObject:self.phone forKey:@"phoneNumber"];
    [coder encodeObject:self.party forKey:@"party"];
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:self.photoURL forKey:@"photoURL"];
    [coder encodeObject:self.photo forKey:@"photo"];
    [coder encodeObject:self.twitter forKey:@"twitter"];
    [coder encodeObject:self.gender forKey:@"gender"];
}
@end