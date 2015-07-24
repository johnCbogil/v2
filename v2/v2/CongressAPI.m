//
//  CongressAPI.m
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "CongressAPI.h"
#import "Congressperson.h"
@interface CongressAPI ()
@property (strong, nonatomic) NSMutableArray *listOfCongressmen;
@end
@implementation CongressAPI

- (void)determineCongressmen:(CLLocation*)currentLocation{
    
    self.listOfCongressmen = [[NSMutableArray alloc]init];
    
    // 1
    NSString *dataUrl = [NSString stringWithFormat:@"http://congress.api.sunlightfoundation.com/legislators/locate?latitude=%f&longitude=%f&apikey=a0c99640cc894383975eb73b99f39d2f", currentLocation.coordinate.latitude,  currentLocation.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    
    // 2
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                                              NSMutableDictionary *decodedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                              NSMutableArray *results = [decodedData valueForKey:@"results"];
                                              //NSLog(@"%@", results);
                                              for(int i = 0; i < results.count; i++){
                                              
                                                  Congressperson *congressperson = [[Congressperson alloc]initWithData:results[i]];
                                                  [self.listOfCongressmen addObject:congressperson];
                                              }
}];
    
    // 3
    [downloadTask resume];
    
}
@end
