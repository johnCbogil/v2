//
//  CompletedAction.m
//  Voices
//
//  Created by John Bogil on 10/11/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "CompletedAction.h"

@interface CompletedAction()

@property (strong, nonatomic) NSString *timestamp;
@property (strong, nonatomic) NSArray *usersCheered;

@end

@implementation CompletedAction

- (instancetype)initWithData:(NSDictionary *)data {
    
    self.timestamp = [data valueForKey:@"timestamp"];
    self.usersCheered = [data valueForKey:@"usersCheered"]; // THIS MAY NEED TO BE A DICT INSTEADf
    
    return self;
}

@end
