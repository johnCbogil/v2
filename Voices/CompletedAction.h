//
//  CompletedAction.h
//  Voices
//
//  Created by John Bogil on 10/11/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompletedAction : NSObject

- (instancetype)initWithData:(NSDictionary *)data;
@property (nonatomic) int long timestamp;
@property (strong, nonatomic) NSArray *usersCheered;

@end
