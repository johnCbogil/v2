//
//  InfluenceExplorer.m
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "InfluenceExplorer.h"

@implementation InfluenceExplorer
- (void)idLookup:(NSString*)bioguideID{
    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"http://transparencydata.com/api/1.0/entities/id_lookup.json?bioguide_id=%@&apikey=a0c99640cc894383975eb73b99f39d2f", bioguideID];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    
    // 2
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              NSMutableDictionary *decodedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                              NSLog(@"%@", decodedData);
                                          }];
    
    // 3
    [downloadTask resume];
}
- (void)determineTopContributors:(NSString*)entityID{
    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"transparencydata.com/api/1.0/aggregates/pol/%@/contributors.json?cycle=2012&limit=10&apikey=a0c99640cc894383975eb73b99f39d2f", entityID];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    
    // 2
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              NSMutableDictionary *decodedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                              NSLog(@"%@", decodedData);
                                          }];
    
    // 3
    [downloadTask resume];
}
- (void)determineTopIndustries:(NSString*)entityID{
    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"transparencydata.com/api/1.0/aggregates/pol/%@/contributors/industries.json?cycle=2012&limit=10&apikey=a0c99640cc894383975eb73b99f39d2f", entityID];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    
    // 2
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              NSMutableDictionary *decodedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                              NSLog(@"%@", decodedData);
                                          }];
    
    // 3
    [downloadTask resume];
}

@end
