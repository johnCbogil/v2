//
//  PolicyPosition.h
//  Voices
//
//  Created by John Bogil on 7/8/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PolicyPosition : NSObject

- (instancetype)initWithKey:(NSString *)key policyPosition:(NSString *)policyPosition;

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *policyPosition;

@end
