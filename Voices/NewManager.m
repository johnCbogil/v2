//
//  NewManager.m
//  Voices
//
//  Created by John Bogil on 11/13/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NewManager.h"

@implementation NewManager

+ (NewManager *) sharedInstance {
    static NewManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
//        self.manager = [AFHTTPRequestOperationManager manager];
        //        self.missingRepresentativePhoto = [UIImage imageNamed:@"MissingRep"];
        //        [self.missingRepresentativePhoto setAccessibilityIdentifier:@"MissingRep"];
    }
    return self;
}

@end
