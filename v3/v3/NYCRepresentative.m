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
        self.name = data[0];
        self.districtNumber = data[1];
        self.borough = data[2];
        self.party = data[3];
        self.districtAddress = data[4];
        self.districtPhone = data[5];
        self.legAddress = data[6];
        self.legPhone = data[7];
        self.email = data[8];
        self.photoURL = [NSURL URLWithString:data[9]];
        self.twitter = data[10];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.districtNumber = [decoder decodeObjectForKey:@"districtNumber"];
        self.borough = [decoder decodeObjectForKey:@"borough"];
        self.party = [decoder decodeObjectForKey:@"party"];
        self.districtAddress = [decoder decodeObjectForKey:@"districtAddress"];
        self.districtPhone = [decoder decodeObjectForKey:@"districtPhone"];
        self.legAddress = [decoder decodeObjectForKey:@"legAddress"];
        self.legPhone = [decoder decodeObjectForKey:@"legPhone"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.photoURL = [decoder decodeObjectForKey:@"photoURL"];
        self.photo = [decoder decodeObjectForKey:@"photo"];
        self.photoURL = [decoder decodeObjectForKey:@"photoURL"];
        self.twitter = [decoder decodeObjectForKey:@"twitter"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.districtNumber forKey:@"districtNumber"];
    [coder encodeObject:self.borough forKey:@"borough"];
    [coder encodeObject:self.party forKey:@"party"];
    [coder encodeObject:self.districtAddress forKey:@"districtAddress"];
    [coder encodeObject:self.districtPhone forKey:@"districtPhone"];
    [coder encodeObject:self.legAddress forKey:@"legAddress"];
    [coder encodeObject:self.legPhone forKey:@"legPhone"];
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:self.photoURL forKey:@"photoURL"];
    [coder encodeObject:self.photo forKey:@"photo"];
    [coder encodeObject:self.photoURL forKey:@"photoURL"];
    [coder encodeObject:self.twitter forKey:@"twitter"];
}
@end