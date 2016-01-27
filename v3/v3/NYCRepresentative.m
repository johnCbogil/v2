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
    NSLog(@"%@", data);
    self = [super init];
    if (self != nil) {
        self.name = [data valueForKey:@"name"];
        self.address = [data valueForKey:@"address"];
        self.email = [data valueForKey:@"emails"];
        self.party = [data valueForKey:@"party"];
        self.photoURL = [NSURL URLWithString:[data valueForKey:@"photoUrl"]];
        self.phone = [data valueForKey:@"phones"][0];
    }
    return self;
}
@end