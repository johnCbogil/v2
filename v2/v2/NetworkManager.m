//
//  NetworkManager.m
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "NetworkManager.h"
#import "LocationService.h"

@implementation NetworkManager
+(NetworkManager *) sharedInstance
{
    static NetworkManager *instance = nil;
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


- (void)determineCongressmenWithCompletion:(void(^)(NSArray *results))successBlock
                                   onError:(void(^)(NSError *error))errorBlock {
    
    CLLocation *currentLocation = [LocationService sharedInstance].currentLocation;
    
    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"http://congress.api.sunlightfoundation.com/legislators/locate?latitude=%f&longitude=%f&apikey=a0c99640cc894383975eb73b99f39d2f", currentLocation.coordinate.latitude,  currentLocation.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    
    // 2
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              NSMutableDictionary *decodedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                              NSMutableArray *results = [decodedData valueForKey:@"results"];
                                              NSLog(@"%@", results);

                                              if (error) {
                                                  errorBlock(error);
                                              }
                                              else{
                                              successBlock(results);
                                              }
                                              
                                          }];
    
    // 3
    [downloadTask resume];
    
}

//- (void)determineStateLegislators:(CLLocation*)currentLocation{
//    self.listOfStateLegislators = [[NSMutableArray alloc]init];
//    
//    // 1
//    NSString *dataUrl = [NSString stringWithFormat:@"http://openstates.org/api/v1//legislators/geo/?lat=%f&long=%f&apikey=a0c99640cc894383975eb73b99f39d2f", currentLocation.coordinate.latitude,  currentLocation.coordinate.longitude];
//    NSURL *url = [NSURL URLWithString:dataUrl];
//    
//    
//    // 2
//    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
//                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                              
//                                              NSMutableArray *decodedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                                              //NSLog(@"%@", decodedData);
//                                              for(int i = 0; i < decodedData.count; i++){
//                                                  
//                                                  StateLegislator *stateLegislator = [[StateLegislator alloc]initWithData:decodedData[i]];
//                                                  [self.listOfStateLegislators addObject:stateLegislator];
//                                              }
//                                              
//                                          }];
//    
//    // 3
//    [downloadTask resume];
//}
//- (void)idLookup:(NSString*)bioguideID{
//    // 1
//    NSString *dataUrl = [NSString stringWithFormat:@"http://transparencydata.com/api/1.0/entities/id_lookup.json?bioguide_id=%@&apikey=a0c99640cc894383975eb73b99f39d2f", bioguideID];
//    NSURL *url = [NSURL URLWithString:dataUrl];
//    
//    
//    // 2
//    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
//                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                              
//                                              NSMutableDictionary *decodedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                                              NSLog(@"%@", decodedData);
//                                          }];
//    
//    // 3
//    [downloadTask resume];
//}
//- (void)determineTopContributors:(NSString*)entityID{
//    // 1
//    NSString *dataUrl = [NSString stringWithFormat:@"transparencydata.com/api/1.0/aggregates/pol/%@/contributors.json?cycle=2012&limit=10&apikey=a0c99640cc894383975eb73b99f39d2f", entityID];
//    NSURL *url = [NSURL URLWithString:dataUrl];
//    
//    
//    // 2
//    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
//                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                              
//                                              NSMutableDictionary *decodedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                                              NSLog(@"%@", decodedData);
//                                          }];
//    
//    // 3
//    [downloadTask resume];
//}
//- (void)determineTopIndustries:(NSString*)entityID{
//    // 1
//    NSString *dataUrl = [NSString stringWithFormat:@"transparencydata.com/api/1.0/aggregates/pol/%@/contributors/industries.json?cycle=2012&limit=10&apikey=a0c99640cc894383975eb73b99f39d2f", entityID];
//    NSURL *url = [NSURL URLWithString:dataUrl];
//    
//    
//    // 2
//    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
//                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                              
//                                              NSMutableDictionary *decodedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                                              NSLog(@"%@", decodedData);
//                                          }];
//    
//    // 3
//    [downloadTask resume];
//}
@end
