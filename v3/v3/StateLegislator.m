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
        self.party = [data valueForKey:@"party"];
        self.phone = [[data valueForKey:@"offices"]valueForKey:@"phone"][0];
        self.photoURL = [NSURL URLWithString:[data valueForKey:@"photo_url"]];
        self.email = [data valueForKey:@"email"];
        self.districtNumber = [data valueForKey:@"district"];
        self.stateCode = [data valueForKey:@"state"];
        self.chamber = [data valueForKey:@"chamber"];
        [self prepareDistrictInformationLabel:self.stateCode.uppercaseString chamber:self.chamber district:self.districtNumber];
        
        // DONT REMEMBER WHAT THIS WAS FOR
        
    //    if ([data valueForKey:@"+party"]) {
            //self.party = [[data valueForKey:@"+party"]substringToIndex: MIN(1, [[data valueForKey:@"+party"] length])].capitalizedString;
  //      }
//        else {
            self.party = [[data valueForKey:@"party"]substringToIndex: MIN(1, [[data valueForKey:@"party"] length])].capitalizedString;
//        }
        return self;
    }
    return self;
}

- (void)prepareDistrictInformationLabel:(NSString*)stateCode chamber:(NSString*)chamberName district:(NSString*)districtNumber{
    NSDictionary *districtInfoDictionary = @{@"stateCode" : stateCode, @"chamber" : chamberName, @"districtNumber" : districtNumber, @"legislatureLevel" : @"State"};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateInformationLabel" object:nil userInfo:districtInfoDictionary];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.firstName = [decoder decodeObjectForKey:@"first_name"];
        self.lastName = [decoder decodeObjectForKey:@"last_Name"];
        //self.nickname = [decoder decodeObjectForKey:@"nickname"];
        //self.bioguide = [decoder decodeObjectForKey:@"bioguide_id"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.party = [decoder decodeObjectForKey:@"party"];
        self.email = [decoder decodeObjectForKey:@"email"];
        //self.twitter = [decoder decodeObjectForKey:@"twitter_id"];
        self.districtNumber = [decoder decodeObjectForKey:@"district"];
        self.stateCode = [decoder decodeObjectForKey:@"state"];
        //self.nextElection = [decoder decodeObjectForKey:@"nextElection"];
        //self.title = [decoder decodeObjectForKey:@"title"];
        //self.shortTitle = [decoder decodeObjectForKey:@"shortTitle"];
        self.photo = [decoder decodeObjectForKey:@"photo"];
        self.chamber = [decoder decodeObjectForKey:@"chamber"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.firstName forKey:@"first_Name"];
    [coder encodeObject:self.lastName forKey:@"last_Name"];
    //[coder encodeObject:self.nickname forKey:@"nickname"];
    //[coder encodeObject:self.bioguide forKey:@"bioguide_id"];
    [coder encodeObject:self.phone forKey:@"phone"];
    [coder encodeObject:self.party forKey:@"party"];
    [coder encodeObject:self.email forKey:@"email"];
    //[coder encodeObject:self.twitter forKey:@"twitter_id"];
    [coder encodeObject:self.districtNumber forKey:@"district"];
    [coder encodeObject:self.stateCode forKey:@"state"];
    //[self prepareDistrictInformation:self.districtNumber state:self.stateCode legislatureLevel:@"Congress"];
//    [coder encodeObject:self.nextElection forKey:@"nextElection"];
//    [coder encodeObject:self.title forKey:@"title"];
//    [coder encodeObject:self.shortTitle forKey:@"shortTitle"];
    [coder encodeObject:self.photo forKey:@"photo"];
    [coder encodeObject:self.chamber forKey:@"chamber"];
}
@end