//
//  OpenStatesAPI.m
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "OpenStatesAPI.h"
#import "StateLegislator.h"

@implementation OpenStatesAPI

- (void)determineStateLegislators:(CLLocation*)currentLocation{
    self.listOfStateLegislators = [[NSMutableArray alloc]init];
    
    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"http://openstates.org/api/v1//legislators/geo/?lat=%f&long=%f&apikey=a0c99640cc894383975eb73b99f39d2f", currentLocation.coordinate.latitude,  currentLocation.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    
    // 2
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              NSMutableArray *decodedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                              NSLog(@"%@", decodedData);
                                              for(int i = 0; i < decodedData.count; i++){
                                                  
                                                  StateLegislator *stateLegislator = [[StateLegislator alloc]initWithData:decodedData[i]];
                                                  [self.listOfStateLegislators addObject:stateLegislator];
                                              }NSLog(@"%@", self.listOfStateLegislators);
                                              
                                          }];
    
    // 3
    [downloadTask resume];
}
@end
