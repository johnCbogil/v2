//
//  Action.h
//  Voices
//
//  Created by David Weissler on 6/6/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Action : NSObject

@property (readonly, nonatomic, copy) NSString *key;
@property (readonly, nonatomic, copy) NSString *body;
@property (readonly, nonatomic, copy) NSString *title;
@property (readonly, nonatomic, copy) NSString *groupName;
@property (readonly, nonatomic, copy) NSString *groupKey;
@property (readonly, nonatomic, copy) NSString *timestamp;
@property (readonly, nonatomic, copy) NSURL *groupImageURL;

- (instancetype)initWithKey:(NSString *)key actionDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
