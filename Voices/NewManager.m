//
//  NewManager.m
//  Voices
//
//  Created by John Bogil on 11/13/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NewManager.h"

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
@end
