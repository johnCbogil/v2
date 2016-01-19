//
//  StateLegislator.m
//  v3
//
//  Created by John Bogil on 7/24/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "StateLegislator.h"

@implementation StateLegislator
- (id)initWithData:(NSDictionary*)data {
    self = [super init];
    if(self != nil) {
        self.firstName = [data valueForKey:@"first_name"];
        self.lastName = [data valueForKey:@"last_name"];
        self.party = [data valueForKey:@"party"];
        self.phone = [[data valueForKey:@"offices"]valueForKey:@"phone"][0];
        self.photoURL = [NSURL URLWithString:[data valueForKey:@"photo_url"]];
        self.email = [data valueForKey:@"email"];
        self.districtNumber = [data valueForKey:@"district"];
        self.stateCode = [data valueForKey:@"state"];
        if ([[data valueForKey:@"chamber"] isEqualToString:@"upper"]) {
            self.chamber = @"Sen.";
        }
        else {
            self.chamber = @"Rep.";
        }
        self.party = [[data valueForKey:@"party"]substringToIndex: MIN(1, [[data valueForKey:@"party"] length])].capitalizedString;
        return self;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.firstName = [decoder decodeObjectForKey:@"first_name"];
        self.lastName = [decoder decodeObjectForKey:@"last_name"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.party = [decoder decodeObjectForKey:@"party"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.districtNumber = [decoder decodeObjectForKey:@"district"];
        self.stateCode = [decoder decodeObjectForKey:@"state"];
        self.photo = [decoder decodeObjectForKey:@"photo"];
        self.chamber = [decoder decodeObjectForKey:@"chamber"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.firstName forKey:@"first_name"];
    [coder encodeObject:self.lastName forKey:@"last_name"];
    [coder encodeObject:self.phone forKey:@"phone"];
    [coder encodeObject:self.party forKey:@"party"];
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:self.districtNumber forKey:@"district"];
    [coder encodeObject:self.stateCode forKey:@"state"];
    [coder encodeObject:self.photo forKey:@"photo"];
    [coder encodeObject:self.chamber forKey:@"chamber"];
}
@end