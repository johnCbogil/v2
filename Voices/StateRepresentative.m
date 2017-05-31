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
        NSArray *offices = [data valueForKey:@"offices"];
        NSArray *phones = [offices valueForKey:@"phone"];
        if (phones.count > 0) {
            self.phone = [offices valueForKey:@"phone"][0];
            if([self.phone isKindOfClass:[NSString class]] && !self.phone.length) {
                self.phone = [[data valueForKey:@"offices"]valueForKey:@"phone"][1];
            }
        }
        self.photoURL = [NSURL URLWithString:[data valueForKey:@"photo_url"]];
        self.email = [data valueForKey:@"email"];
        self.districtNumber = [data valueForKey:@"district"];
        self.stateCode = [data valueForKey:@"state"];
        self.stateName = [data valueForKey:@"stateFull"];
        //self.gender = [data valueForKey:@"gender"];
        // Add state property.
        if ([[data valueForKey:@"chamber"] isEqualToString:@"upper"]) {
            self.shortTitle = @"Sen.";
            self.title = @"Senator "; //space differentiates state Sen. from Federal. refactor needed
        }
        else {
            self.shortTitle = @"Rep.";
            self.title = @"Representative";
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
        self.stateName = [data valueForKey:@"state_full"];
        self.shortTitle = @"Gov.";
        self.title = @"Governor";
        self.party = [[data valueForKey:@"party"]substringToIndex: MIN(1, [[data valueForKey:@"party"] length])].capitalizedString;
        self.nextElection = [self formatElectionDate:[data valueForKey:@"next_election_date"]];
        self.twitter = [data valueForKey:@"twitter"];
        self.gender = [data valueForKey:@"gender"];
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

@end
