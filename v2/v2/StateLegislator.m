//
//  StateLegislator.m
//  v2
//
//  Created by John Bogil on 7/24/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "StateLegislator.h"

@implementation StateLegislator
- (id)initWithData:(NSMutableArray*)data {
    self = [super init];
    if(self != nil) {

        self.firstName = [data valueForKey:@"first_name"];
        return self;
    }
    return self;
}
@end
