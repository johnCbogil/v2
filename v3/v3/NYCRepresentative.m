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
    self = [super init];
    if (self != nil) {
        NSLog(@"%@",data);
    }
    return self;
}
@end
