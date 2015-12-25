//
//  StateLegislator.m
//  v2
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
        self.party = [data valueForKey:@"+party"];
        self.phone = [[data valueForKey:@"offices"]valueForKey:@"phone"][0];
        self.photoURL = [NSURL URLWithString:[data valueForKey:@"photo_url"]];
        self.email = [data valueForKey:@"email"];
        self.districtInfo = [data valueForKey:@"+district"];
        self.stateCode = [data valueForKey:@"state"];
        if ([data valueForKey:@"+party"]) {
            self.party = [[data valueForKey:@"+party"]substringToIndex: MIN(1, [[data valueForKey:@"+party"] length])].capitalizedString;
        }
        else {
            self.party = [[data valueForKey:@"party"]substringToIndex: MIN(1, [[data valueForKey:@"party"] length])].capitalizedString;
        }
        return self;
    }
    return self;
}

- (void)prepareDistrictInformation:(NSString*)districtNumber state:(NSString*)stateCode legislatureLevel:(NSString*)level{
    NSDictionary *districtInfoDictionary = @{@"districtNumber" : districtNumber, @"stateCode" : stateCode, @"legislatureLevel", level};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateInformationLabel" object:nil userInfo:districtInfoDictionary];
}
@end