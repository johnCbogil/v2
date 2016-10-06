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
        self.fullName = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
        self.phone = data[@"phoneNumber"];
        self.email = data[@"email"];
        self.party = data[@"party"];
        self.photoURL = [NSURL URLWithString:data[@"photoURLPath"]];
        self.twitter = data[@"twitter"];
        self.gender = data[@"gender"];
        self.title = data[@"title"] ? data[@"title"] : @"Council Member";
        self.nextElection = data[@"nextElection"];
    }
    return self;
}

@end
