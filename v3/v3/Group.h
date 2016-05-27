//
//  Group.h
//  Voices
//
//  Created by Bogil, John on 5/27/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *key;
- (id)initWithKey:(NSString *)key andValue:(NSDictionary *)value;

@end
