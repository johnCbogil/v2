//
//  SunlightFoundationAPI.m
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "SunlightFoundationAPI.h"

@implementation SunlightFoundationAPI
- (id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)determineCongressmen{
    
    
    // 1
    NSString *dataUrl = @"http://congress.api.sunlightfoundation.com/legislators/locate?latitude=40.753678&longitude=-73.682834&apikey=a0c99640cc894383975eb73b99f39d2f";
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
