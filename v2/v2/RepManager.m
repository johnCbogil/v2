//
//  RepManager.m
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "RepManager.h"
#import "NetworkManager.h"
#import "Congressperson.h"
#import "StateLegislator.h"

@implementation RepManager

+ (RepManager *)sharedInstance
{
    static RepManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        self.listOfCongressmen = [NSArray array];
    }
    return self;
}

- (void)createCongressmen:(void(^)(void))successBlock
                     onError:(void(^)(NSError *error))errorBlock {
    [[NetworkManager sharedInstance]getCongressmenWithCompletion:^(NSArray *results) {
        NSMutableArray *listOfCongressmen = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in results) {
            Congressperson *congressperson = [[Congressperson alloc] initWithData:resultDict];
            [listOfCongressmen addObject:congressperson];
        }
        self.listOfCongressmen = listOfCongressmen;
        if (successBlock) {
            
            successBlock();
        }
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)createStateLegislators:(void(^)(void))successBlock
                       onError:(void(^)(NSError *error))errorBlock {
    
    [[NetworkManager sharedInstance]getStateLegislatorsWithCompletion:^(NSArray *results) {
        NSMutableArray *listofStateLegislators = [[NSMutableArray alloc]init];
        for(NSDictionary *resultDict in results){
            StateLegislator *stateLegislator = [[StateLegislator alloc]initWithData:resultDict];
            [listofStateLegislators addObject:stateLegislator];
        }
        self.listofStateLegislators = listofStateLegislators;
        if (successBlock) {
            successBlock();
        }
    } onError:^(NSError *error){
        errorBlock(error);
    }];
}


@end
