//
//  Congressperson.m
//  v3
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "Congressperson.h"

@implementation Congressperson

- (id)initWithData:(NSDictionary *)data {
    self = [super init];
    if(self != nil) {
        self.firstName = [data valueForKey:@"first_name"];
        self.lastName = [data valueForKey:@"last_name"];
        self.nickname = [data valueForKey:@"nickname"];
        self.bioguide = [data valueForKey:@"bioguide_id"];
        self.phone = [data valueForKey:@"phone"];
        self.party = [data valueForKey:@"party"];
        self.email = [data valueForKey:@"oc_email"];
        self.twitter = [data valueForKey:@"twitter_id"];
        self.districtNumber = [data valueForKey:@"district"];
        self.stateCode = [data valueForKey:@"state"];
        self.nextElection = [self formatElectionDate:[data valueForKey:@"term_end"]];
        if ([[data valueForKey:@"title"]isEqualToString:@"Sen"]) {
            self.title = @"Senator";
            self.shortTitle = @"Sen";
        }
        else {
            self.title = @"Representative";
            self.shortTitle = @"Rep";
        }
        return self;
    }
    return self;
}

- (NSString*)formatElectionDate:(NSString*)termEnd {
//    if([termEnd isEqualToString:@"2017-01-03"] || [termEnd isEqualToString:@"2019-01-03"]){
//        return @"4 Nov 2016";
//    }
//    
//    else {
//        return  @"3 Nov 2020";
//    }
    if ([termEnd isEqualToString:@"2019-01-03"]) {
        return @"6 Nov 2018";
    }
    else if ([termEnd isEqualToString:@"2017-01-03"]) {
        return @"8 Nov 2016";
    }
    else {
        return @"3 Nov 2020";
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.nickname = [decoder decodeObjectForKey:@"nickname"];
        self.bioguide = [decoder decodeObjectForKey:@"bioguide_id"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.party = [decoder decodeObjectForKey:@"party"];
        self.email = [decoder decodeObjectForKey:@"oc_email"];
        self.twitter = [decoder decodeObjectForKey:@"twitter_id"];
        self.districtNumber = [decoder decodeObjectForKey:@"district"];
        self.stateCode = [decoder decodeObjectForKey:@"state"];
        self.nextElection = [decoder decodeObjectForKey:@"nextElection"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.shortTitle = [decoder decodeObjectForKey:@"shortTitle"];
        self.photo = [decoder decodeObjectForKey:@"photo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.firstName forKey:@"firstName"];
    [coder encodeObject:self.lastName forKey:@"lastName"];
    [coder encodeObject:self.nickname forKey:@"nickname"];
    [coder encodeObject:self.bioguide forKey:@"bioguide_id"];
    [coder encodeObject:self.phone forKey:@"phone"];
    [coder encodeObject:self.party forKey:@"party"];
    [coder encodeObject:self.email forKey:@"oc_email"];
    [coder encodeObject:self.twitter forKey:@"twitter_id"];
    [coder encodeObject:self.districtNumber forKey:@"district"];
    [coder encodeObject:self.stateCode forKey:@"state"];
    [coder encodeObject:self.nextElection forKey:@"nextElection"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.shortTitle forKey:@"shortTitle"];
    [coder encodeObject:self.photo forKey:@"photo"];
}
@end