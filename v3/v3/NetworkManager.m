//
//  NetworkManager.m
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//  AIzaSyBGpp2MpyG6zmf7gHcXqNro2bom1roCfVQ

#import "NetworkManager.h"
#import "LocationService.h"

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
    }
    return self;
}

- (void)getCongressmenFromLocation:(CLLocation*)location WithCompletion:(void(^)(NSDictionary *results))successBlock
                           onError:(void(^)(NSError *error))errorBlock {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleZeroStateLabel" object:nil];
    NSString *dataUrl = [NSString stringWithFormat:@"https://congress.api.sunlightfoundation.com/legislators/locate?latitude=%f&longitude=%f&apikey=a0c99640cc894383975eb73b99f39d2f", location.coordinate.latitude,  location.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"%@", responseObject);
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"endRefreshing" object:nil];
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

- (void)getStateLegislatorsFromLocation:(CLLocation*)location WithCompletion:(void(^)(NSDictionary *results))successBlock onError:(void(^)(NSError *error))errorBlock {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleZeroStateLabel" object:nil];
    // OPEN STATES DOES NOT ALLOW FOR SECURE CONNECTIONS
    NSString *dataUrl = [NSString stringWithFormat:@"http://openstates.org/api/v1//legislators/geo/?lat=%f&long=%f&apikey=a0c99640cc894383975eb73b99f39d2f", location.coordinate.latitude,  location.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@", responseObject);
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"endRefreshing" object:nil];
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

- (void)getCongressPhotos:(NSString*)bioguide withCompletion:(void(^)(UIImage *results))successBlock
                  onError:(void(^)(NSError *error))errorBlock {
    NSString *dataUrl = [NSString stringWithFormat:@"https://theunitedstates.io/images/congress/450x550/%@.jpg", bioguide];
    NSURL *url = [NSURL URLWithString:dataUrl];
    NSLog(@"%@", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
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

- (void)getStatePhotos:(NSURL*)photoURL withCompletion:(void(^)(UIImage *results))successBlock
               onError:(void(^)(NSError *error))errorBlock {
    NSURLRequest *request = [NSURLRequest requestWithURL:photoURL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"%@", responseObject);
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        UIImage *missingRep = [UIImage imageNamed:@"MissingRep"];
        [missingRep setAccessibilityIdentifier:@"MissingRep"];
        successBlock(missingRep);
    }];
    
    [operation start];
}

- (void)idLookup:(NSString*)bioguide withCompletion:(void(^)(NSArray *results))successBlock
         onError:(void(^)(NSError *error))errorBlock {
    NSString *dataUrl = [NSString stringWithFormat:@"https://transparencydata.com/api/1.0/entities/id_lookup.json?bioguide_id=%@&apikey=a0c99640cc894383975eb73b99f39d2f", bioguide];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"%@", responseObject);
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

- (void)getTopContributors:(NSString*)crpID withCompletion:(void(^)(NSDictionary *results))successBlock
                   onError:(void(^)(NSError *error))errorBlock {
    NSString *dataUrl = [NSString stringWithFormat:@"https://www.opensecrets.org/api/?method=candContrib&cid=%@&cycle=2014&output=json&apikey=9cca34c3d940ed7795c8d9b1f03f90bb", crpID];
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

- (void)getTopIndustries:(NSString*)influenceExplorerID withCompletion:(void(^)(NSArray *results))successBlock
                 onError:(void(^)(NSError *error))errorBlock {
    NSString *dataUrl = [NSString stringWithFormat:@"https://transparencydata.com/api/1.0/aggregates/pol/%@/contributors/industries.json?cycle=2014&limit=10&apikey=a0c99640cc894383975eb73b99f39d2f", influenceExplorerID];
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"%@", responseObject);
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

- (void)getStreetAddressFromSearchText:(NSString*)searchText withCompletion:(void(^)(NSArray *results))successBlock
                               onError:(void(^)(NSError *error))errorBlock {
    
    //AIzaSyBr8fizIgU0OF53heFICd3ak5Yp1EJpviE - googkey
    
    NSString *formattedString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&key=AIzaSyBr8fizIgU0OF53heFICd3ak5Yp1EJpviE", searchText];
    NSString *cleanUrl = [formattedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:cleanUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"%@", responseObject);
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}


//- (void)getCongressmenFromQuery:(NSString*)query WithCompletion:(void(^)(NSDictionary *results))successBlock
//                           onError:(void(^)(NSError *error))errorBlock {
//
//    NSString *parsedQuery = [query componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]][0];
//
//    NSString *dataUrl = [NSString stringWithFormat:@"http://congress.api.sunlightfoundation.com/legislators?query=%@&apikey=a0c99640cc894383975eb73b99f39d2f", parsedQuery];
//    NSString *cleanUrl = [dataUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//    NSURL *url = [NSURL URLWithString:cleanUrl];
//
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//        // NSLog(@"%@", responseObject);
//        successBlock(responseObject);
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//
//        NSLog(@"Error: %@", error);
//    }];
//
//    [operation start];
//}

@end
