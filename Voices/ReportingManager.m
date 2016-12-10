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
    
    NSString *eventType;
    NSString *eventFocus;
    NSString *eventLoggerID;
    NSString *eventData;
    NSString *os;
    
    NSString *reportingURL = [NSString stringWithFormat:@"%@&"];
    
    // IF DEBUG, APPEND DEBUG TO REPORTING URL STRING
    
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
