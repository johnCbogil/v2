//
//  NetworkManager.m
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "NetworkManager.h"
#import "LocationService.h"
#import "AFNetworking.h"

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


- (void)getCongressmenWithCompletion:(void(^)(NSDictionary *results))successBlock
                                   onError:(void(^)(NSError *error))errorBlock {
    
    CLLocation *currentLocation = [LocationService sharedInstance].currentLocation;
    
    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"http://congress.api.sunlightfoundation.com/legislators/locate?latitude=%f&longitude=%f&apikey=a0c99640cc894383975eb73b99f39d2f", currentLocation.coordinate.latitude,  currentLocation.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@", responseObject);
        successBlock([responseObject valueForKey:@"results"]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
    
}

- (void)getStateLegislatorsWithCompletion:(void(^)(NSArray *results))successBlock
                                   onError:(void(^)(NSError *error))errorBlock {
    
    CLLocation *currentLocation = [LocationService sharedInstance].currentLocation;
    
    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"http://openstates.org/api/v1//legislators/geo/?lat=%f&long=%f&apikey=a0c99640cc894383975eb73b99f39d2f", currentLocation.coordinate.latitude,  currentLocation.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@", responseObject);
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

- (void)getCongressPhotos:(NSString*)bioguide withCompletion:(void(^)(UIImage *results))successBlock
                                  onError:(void(^)(NSError *error))errorBlock {
    
//    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"http://theunitedstates.io/images/congress/450x550/%@.jpg", bioguide];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"%@", responseObject);
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

- (void)getStatePhotos:(NSURL*)photoURL withCompletion:(void(^)(UIImage *results))successBlock
               onError:(void(^)(NSError *error))errorBlock {
    
//    // 2
//    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
//                                          dataTaskWithURL:photoURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                              
//                                              if (error) {
//                                                  errorBlock(error);
//                                              }
//                                              else{
//                                                  successBlock(data);
//                                              }
//                                          }];
//    // 3
//    [downloadTask resume];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:photoURL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@", responseObject);
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

- (void)idLookup:(NSString*)bioguide withCompletion:(void(^)(NSData *results))successBlock
               onError:(void(^)(NSError *error))errorBlock {
    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"http://transparencydata.com/api/1.0/entities/id_lookup.json?bioguide_id=%@&apikey=a0c99640cc894383975eb73b99f39d2f", bioguide];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    
    // 2
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              if (error) {
                                                  errorBlock(error);
                                              }
                                              else{
                                                  successBlock(data);
                                              }
                                          }];
    
    // 3
    [downloadTask resume];
}

- (void)getTopContributors:(NSString*)influenceExplorerID withCompletion:(void(^)(NSData *results))successBlock
         onError:(void(^)(NSError *error))errorBlock {
    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"http://transparencydata.com/api/1.0/aggregates/pol/%@/contributors.json?cycle=2014&limit=10&apikey=a0c99640cc894383975eb73b99f39d2f", influenceExplorerID];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    
    // 2
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if (error) {
                                                  errorBlock(error);
                                              }
                                              else{
                                                  successBlock(data);
                                              }
                                          }];
    
    // 3
    [downloadTask resume];
}

// THIS IS THE WRONG URL
- (void)getTopIndustries:(NSString*)influenceExplorerID withCompletion:(void(^)(NSData *results))successBlock
                   onError:(void(^)(NSError *error))errorBlock {
    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"http://transparencydata.com/api/1.0/aggregates/pol/%@/contributors.json?cycle=2014&limit=10&apikey=a0c99640cc894383975eb73b99f39d2f", influenceExplorerID];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    
    // 2
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              if (error) {
                                                  errorBlock(error);
                                              }
                                              else{
                                                  successBlock(data);
                                              }
                                          }];
    
    // 3
    [downloadTask resume];
}
@end
