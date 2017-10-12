//
//  CompletedAction.m
//  Voices
//
//  Created by John Bogil on 10/11/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "CompletedAction.h"

@implementation CompletedAction

- (instancetype)initWithData:(NSDictionary *)data {
    
    self.timestamp = [[data valueForKey:@"timestamp"]intValue];
    self.usersCheered = [[data valueForKey:@"usersCheered"]allKeys]; // THIS MAY NEED TO BE A DICT INSTEADf
    
    return self;
}

@end
