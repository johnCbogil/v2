//
//  NewManager.m
//  Voices
//
//  Created by John Bogil on 11/13/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NewManager.h"
#import "NetworkManager.h"
#import "FederalRepresentative.h"
#import "StateRepresentative.h"

@interface NewManager()

@property (strong, nonatomic) NSArray *fedReps;
@property (strong, nonatomic) NSArray *stateReps;
@property (strong, nonatomic) NSArray *localReps;

@end

@implementation NewManager

+ (NewManager *) sharedInstance {
    static NewManager *instance = nil;
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

- (NSArray *)fetchRepsForIndex:(NSInteger)index {
    if (index == 0) {
        return self.fedReps;
    }
    else if (index == 1) {
        return self.stateReps;
    }
    else if (index == 2) {
        return self.localReps;
    }
    else return @[];
}

#pragma mark - Create Federal Representatives

- (void)createFederalRepresentativesFromLocation:(CLLocation*)location WithCompletion:(void(^)(void))successBlock
                                         onError:(void(^)(NSError *error))errorBlock {
    
    [[NetworkManager sharedInstance]getFederalRepresentativesFromLocation:location WithCompletion:^(NSDictionary *results) {
        
        // THIS FEELS REDUNDANT
        NSMutableArray *listOfFederalRepresentatives = [[NSMutableArray alloc]init];
        for (NSDictionary *resultDict in [results valueForKey:@"results"]) {
            FederalRepresentative *federalRepresentative = [[FederalRepresentative alloc] initWithData:resultDict];
            [listOfFederalRepresentatives addObject:federalRepresentative];
            self.fedReps = listOfFederalRepresentatives;
            successBlock();
        }
        
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark - Create State Representatives

-(void)createStateRepresentativesFromLocation:(CLLocation *)location WithCompletion:(void (^)(void))successBlock onError:(void (^)(NSError *))errorBlock {
    
    [[NetworkManager sharedInstance]getStateRepresentativesFromLocation:location WithCompletion:^(NSDictionary *results) {
        NSMutableArray *listOfStateRepresentatives = [[NSMutableArray alloc]init];
        
        BOOL firstRun = true;
        
        for (NSDictionary *resultDict in results) {
            StateRepresentative *stateRepresentative = [[StateRepresentative alloc] initWithData:resultDict];
            if (firstRun) {
                NSString *stateCode = stateRepresentative.stateCode;
                if (stateCode) {
                    StateRepresentative *governor = [self createGovernors:stateCode];
                    if (governor) {
                        [listOfStateRepresentatives addObject:governor];
                        firstRun = false;
                    }
                }
            }
            
            if (successBlock) {
                [listOfStateRepresentatives addObject:stateRepresentative];
                self.stateReps = listOfStateRepresentatives;
                successBlock();
            }
        }
        
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
}

- (StateRepresentative *)createGovernors:(NSString *)stateCode {
    
    StateRepresentative *governorRepresentative;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"stateGovernors" ofType:@"json"];
    NSData *governorJSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:nil];
    NSDictionary *governorDataDictionary = [NSJSONSerialization JSONObjectWithData:governorJSONData options:NSJSONReadingAllowFragments error:nil];
    for (NSDictionary *governor in governorDataDictionary) {
        if ([[governor valueForKey:@"state"]caseInsensitiveCompare:stateCode] == NSOrderedSame) {
            governorRepresentative = [[StateRepresentative alloc] initGovWithData:governor];
            break;
        }
    }
    return governorRepresentative;
}




@end
