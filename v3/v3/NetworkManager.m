//
//  NetworkManager.m
//  Voices
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//  AIzaSyBGpp2MpyG6zmf7gHcXqNro2bom1roCfVQ

#import "NetworkManager.h"
#import "LocationService.h"
#import "VoicesConstants.h"

@implementation NetworkManager

+(NetworkManager *) sharedInstance {
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
        self.manager = [AFHTTPRequestOperationManager manager];
        self.missingRepresentativePhoto = [UIImage imageNamed:@"MissingRep"];
        [self.missingRepresentativePhoto setAccessibilityIdentifier:@"MissingRep"];
    }
    return self;
}

#pragma mark - Get Federal Representatives

- (void)getFederalRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(NSDictionary *results))successBlock
                           onError:(void(^)(NSError *error))errorBlock {
    NSString *dataUrl = [NSString stringWithFormat:@"https://congress.api.sunlightfoundation.com/legislators/locate?latitude=%f&longitude=%f&apikey=%@", location.coordinate.latitude,  location.coordinate.longitude, kSFCongress];
    NSURL *url = [NSURL URLWithString:dataUrl];
    NSLog(@"%@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"%@", responseObject);
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"endRefreshing" object:nil];
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:nil delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil, nil];
        if (error.code == -1009) {
            alert.message = @"The internet connection appears to be offline";
        }
        else {
            alert.message = @"It appears there was a server error";
        }
        [alert show];
    }];
    [operation start];
}

#pragma mark - Get State Representatives Methods

- (void)getStateRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(NSDictionary *results))successBlock onError:(void(^)(NSError *error))errorBlock {

    NSString *dataUrl = [NSString stringWithFormat:@"http://openstates.org/api/v1//legislators/geo/?lat=%f&long=%f&apikey=%@", location.coordinate.latitude,  location.coordinate.longitude, kSFState];
    NSURL *url = [NSURL URLWithString:dataUrl];
    NSLog(@"%@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
       // NSLog(@"%@", responseObject);
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"endRefreshing" object:nil];
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:nil delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil, nil];
        if (error.code == -1009) {
            alert.message = @"The internet connection appears to be offline";
        }
        else {
            alert.message = @"It appears there was a server error";
        }
        [alert show];
    }];
    [operation start];
}

#pragma mark - Get Street Address Method

- (void)getStreetAddressFromSearchText:(NSString*)searchText withCompletion:(void(^)(NSArray *results))successBlock
                               onError:(void(^)(NSError *error))errorBlock {
    
    NSString *formattedString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&key=%@", searchText, kGoogMaps];
    NSString *encodedURL = [formattedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"%@", responseObject);
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Server Error" message:@"There was a problem with Goolge Maps. Please try again" delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil,nil];
        [alert show];
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}


@end