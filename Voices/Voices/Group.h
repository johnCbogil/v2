//
//  Group.h
//  Voices
//
//  Created by Bogil, John on 5/27/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Group : NSObject

@property (readonly, nonatomic, copy) NSString *key;
@property (readonly, nonatomic, copy) NSString *name;

- (instancetype)initWithKey:(NSString *)key groupDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
