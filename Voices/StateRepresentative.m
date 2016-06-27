//
//  StateRepresentative.m
//  Voices
//
//  Created by John Bogil on 7/24/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "StateRepresentative.h"

@implementation StateRepresentative

- (id)initWithData:(NSDictionary*)data {
    self = [super init];
    if(self != nil) {
        self.firstName = [data valueForKey:@"first_name"];
        self.lastName = [data valueForKey:@"last_name"];
        self.fullName = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
        self.party = [data valueForKey:@"party"];
        self.phone = [[data valueForKey:@"offices"]valueForKey:@"phone"][0];
        self.photoURL = [NSURL URLWithString:[data valueForKey:@"photo_url"]];
        self.email = [data valueForKey:@"email"];
        self.districtNumber = [data valueForKey:@"district"];
        self.stateCode = [data valueForKey:@"state"];
        self.state = [data valueForKey:@"stateFull"];
        // Add state property.
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

- (id)initGovWithData:(NSDictionary*)data {
    self = [super init];
    if (self != nil) {
        self.firstName = [data valueForKey:@"first_name"];
        self.lastName = [data valueForKey:@"last_name"];
        self.fullName = [data valueForKey:@"full_name"];
        self.party = [data valueForKey:@"party"];
        self.phone = [data valueForKey:@"phone"];
        self.photoURL = [NSURL URLWithString:[data valueForKey:@"photo_url"]];
        self.email = [data valueForKey:@"email"];
        self.districtNumber = [data valueForKey:@"district"];
        self.stateCode = [data valueForKey:@"state"];
        self.state = [data valueForKey:@"state_full"];
        self.chamber = @"Gov.";
        self.party = [[data valueForKey:@"party"]substringToIndex: MIN(1, [[data valueForKey:@"party"] length])].capitalizedString;
        self.nextElection = [self formatElectionDate:[data valueForKey:@"next_election_date"]];
        self.twitter = [data valueForKey:@"twitter"];
        return self;
    }
    return self;
}

- (NSString*)formatElectionDate:(NSString*)termEnd {
    if ([termEnd isEqualToString:@"11/6/2018"]) {
        return @"6 Nov 2018";
    }
    else if ([termEnd isEqualToString:@"11/18/2016"]) {
        return @"18 Nov 2016";
    }
    else if ([termEnd isEqualToString:@"11/7/2017"]) {
        return @"7 Nov 2017";
    }
    else if ([termEnd isEqualToString:@"11/1/2019"]) {
        return @"1 Nov 2019";
    }
    else {
        return @"3 Nov 2020";
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.firstName = [decoder decodeObjectForKey:@"first_name"];
        self.lastName = [decoder decodeObjectForKey:@"last_name"];
        self.fullName = [decoder decodeObjectForKey:@"fullName"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.party = [decoder decodeObjectForKey:@"party"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.districtNumber = [decoder decodeObjectForKey:@"district"];
        self.stateCode = [decoder decodeObjectForKey:@"state"];
        self.photo = [decoder decodeObjectForKey:@"photo"];
        self.chamber = [decoder decodeObjectForKey:@"chamber"];
        self.photoURL = [decoder decodeObjectForKey:@"photoURL"];
        self.nextElection = [decoder decodeObjectForKey:@"next_election_date"];
        self.state = [decoder decodeObjectForKey:@"state_full"];
        self.twitter = [decoder decodeObjectForKey:@"twitter"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.firstName forKey:@"first_name"];
    [coder encodeObject:self.lastName forKey:@"last_name"];
    [coder encodeObject:self.fullName forKey:@"fullName"];
    [coder encodeObject:self.phone forKey:@"phone"];
    [coder encodeObject:self.party forKey:@"party"];
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:self.districtNumber forKey:@"district"];
    [coder encodeObject:self.stateCode forKey:@"state"];
    [coder encodeObject:self.photo forKey:@"photo"];
    [coder encodeObject:self.chamber forKey:@"chamber"];
    [coder encodeObject:self.photoURL forKey:@"photoURL"];
    [coder encodeObject:self.nextElection forKey:@"next_election_date"];
    [coder encodeObject:self.state forKey:@"state_full"];
    [coder encodeObject:self.twitter forKey:@"twitter"];
}
@end