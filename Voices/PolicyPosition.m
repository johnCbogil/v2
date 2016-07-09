//
//  PolicyPosition.m
//  Voices
//
//  Created by John Bogil on 7/8/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "PolicyPosition.h"

@implementation PolicyPosition

- (instancetype)initWithKey:(NSString *)key policyPosition:(NSString *)policyPosition {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.key = key;
    self.policyPosition = policyPosition;
    
    return self;
}
    
@end
