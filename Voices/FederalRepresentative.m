//
//  FederalRepresentative.m
//  Voices
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "FederalRepresentative.h"
#import "RepsManager.h"

@interface FederalRepresentative()

@property (strong, nonatomic) NSNumber *officialIndex;

@end

@implementation FederalRepresentative


- (id)initWithData:(NSDictionary *)data {
    self = [super init];
    if(self != nil) {
        
        
        self.firstName = data[@"firstName"];
        self.lastName = data[@"lastName"];
        self.fullName = [NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName];
        self.party = data[@"officeParties"];
        self.stateCode = data[@"officeStateId"];
        self.candidateId = data[@"candidateId"];
        
        
        
//        NSDictionary *office = data[@"office"];
//        NSArray *roles = office[@"roles"];
//        if ([roles[0]isEqualToString:@"legislatorUpperBody"]) {
//            self.title = @"Senator";
//        }
//        else {
//            self.title = @"Representative";
//        }
//        self.fullName = data[@"name"];
//        self.phone = data[@"phones"][0];
//        self.phone = [self.phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
//        self.phone = [self.phone stringByReplacingOccurrencesOfString:@")" withString:@""];
//        self.phone = [self.phone stringByReplacingOccurrencesOfString:@" " withString:@""];
//        self.phone = [self.phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
//        self.party = data[@"party"];
//        self.photoURL = [NSURL URLWithString:data[@"photoUrl"]];
//        NSArray *channels = data[@"channels"];
//        for (NSDictionary *channel in channels) {
//            if ([channel[@"type"]isEqualToString:@"Twitter"]) {
//                self.twitter = [NSString stringWithFormat:@"@%@",channel[@"id"]];
//            }
//        }
        
        
        return self;
    }
    return self;
}

- (NSURL *)createPhotoURLFromBioguide:(NSString *)bioguide {
    NSString *dataUrl = [NSString stringWithFormat:@"https://theunitedstates.io/images/congress/225x275/%@.jpg", bioguide];
    NSURL *url = [NSURL URLWithString:dataUrl];
    return url;
}

- (NSString*)formatElectionDate:(NSString*)termEnd {
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

- (void)formatTitle:(NSString*)data {
    if ([data isEqualToString:@"Sen"]) {
        self.title = @"Senator";
        self.shortTitle = @"Sen.";
    }
    else {
        self.title = @"Representative";
        self.shortTitle = @"Rep.";
    }
}

@end
