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
@import Firebase;

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
    
    NSString *eventLoggerID = [FIRAuth auth].currentUser.uid;
    NSString *platform = @"iOS";
    NSString *osVersion = [[NSProcessInfo processInfo] operatingSystemVersionString];
    NSString *currentTime = [self getCurrentTime];

#ifdef DEBUG
    eventType = [@"DEBUG_" stringByAppendingString:eventType];
#endif
    NSString *params = [NSString stringWithFormat:@"eventType=%@&eventFocus=%@&eventData=%@&eventLoggerId=%@&platform=%@&osVersion=%@&eventTime=%@", eventType, eventFocus, eventData, eventLoggerID, platform, osVersion, currentTime];
    NSString *reportingString = [NSString stringWithFormat:@"%@%@", kEVENT_DATABASE, params];
    
    NSMutableCharacterSet *alphaNumSymbols = [NSMutableCharacterSet characterSetWithCharactersInString:@"~!@#$&*()-_+=[]:;',/?."];
    [alphaNumSymbols formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    
    reportingString = [reportingString stringByAddingPercentEncodingWithAllowedCharacters:alphaNumSymbols];
    
    NSURL *url = [NSURL URLWithString: reportingString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"endRefreshing" object:nil];
    }];
    [operation start];
}

- (NSString *)getCurrentTime {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *timeZoneName = [timeZone localizedName:NSTimeZoneNameStyleShortStandard locale:[NSLocale currentLocale]];
    NSString *dateString = [NSString stringWithFormat:@"%@ %@",[dateFormat stringFromDate:[NSDate date]],timeZoneName];
    return dateString;
}

@end
