//
//  Group.h
//  Voices
//
//  Created by Bogil, John on 5/27/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Action.h"
NS_ASSUME_NONNULL_BEGIN

@interface Group : NSObject

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *groupDescription;
@property (strong, nonatomic) NSString *groupType;
@property (strong, nonatomic) NSURL *groupImageURL;
@property (strong, nonatomic) NSArray <NSString*> *actionKeys;
@property BOOL debug;

+ (Group *)groupForAction: (Action*) action;
- (instancetype)initWithKey:(NSString *)key groupDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
