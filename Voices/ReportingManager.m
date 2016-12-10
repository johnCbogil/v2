//
//  ReportingManager.m
//  Voices
//
//  Created by John Bogil on 12/10/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ReportingManager.h"

@implementation ReportingManager

+ (ReportingManager *) sharedInstance {
    static ReportingManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        
    }
    return self;
}

- (void)reportEvent {
    
}

@end
