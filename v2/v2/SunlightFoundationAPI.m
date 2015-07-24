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

- (void)determineCongressmen:(CLLocation*)currentLocation{

    
    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"http://congress.api.sunlightfoundation.com/legislators/locate?latitude=%f&longitude=%f&apikey=a0c99640cc894383975eb73b99f39d2f", currentLocation.coordinate.latitude,  currentLocation.coordinate.longitude];
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
