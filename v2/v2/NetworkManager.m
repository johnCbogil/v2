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
    
   // self.listOfCongressmen = [[NSMutableArray alloc]init];
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
//                                              for(int i = 0; i < results.count; i++){
//                                                  
//                                                  Congressperson *congressperson = [[Congressperson alloc]initWithData:results[i]];
//                                                  [self.listOfCongressmen addObject:congressperson];
//                                              }
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
@end
