//
//  Congressperson.m
//  v2
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
        self.crpID = [data valueForKey:@"crp_id"];
        self.party = [data valueForKey:@"party"];
        self.email = [data valueForKey:@"oc_email"];
        self.twitter = [data valueForKey:@"twitter_id"];
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
    if([termEnd isEqualToString:@"2017-01-03"] || [termEnd isEqualToString:@"2019-01-03"]){
        return @"4 Nov 2016";
    }

    else {
        return  @"3 Nov 2020";
    }
}
@end
