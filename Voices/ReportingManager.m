//
//  ReportingManager.m
//  Voices
//
//  Created by John Bogil on 12/10/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ReportingManager.h"
#import "AFHTTPRequestOperation.h"
#import "CurrentUser.h"
#import "AppDelegate.h"

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

- (void)reportEvent:(NSString *)eventType eventFocus:(NSString *)eventFocus eventData:(NSString *)eventData {
    
#ifdef DEBUG
    
    RETURN;
    
#endif
    
    NSString *eventLoggerID;
    NSString *osVersion = [[NSProcessInfo processInfo] operatingSystemVersionString];
    
    NSString *reportingURL = [NSString stringWithFormat:@"%@&%@&%@&%@&%@", eventType, eventFocus, eventData, eventLoggerID, osVersion];
    
    NSURL *url = [NSURL URLWithString:reportingURL];
    
    NSLog(@"%@", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"%@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"endRefreshing" object:nil];
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

@end
