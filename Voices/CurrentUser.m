//
//  CurrentUser.m
//  Voices
//
//  Created by Bogil, John on 9/1/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "CurrentUser.h"
#import "ReportingManager.h"

@interface CurrentUser()

@end

@implementation CurrentUser

+ (CurrentUser *) sharedInstance {
    static CurrentUser *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        
        self.listOfFollowedGroups = @[].mutableCopy;
    }
    return self;
}

@end
