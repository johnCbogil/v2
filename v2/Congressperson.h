//
//  Congressperson.h
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Congressperson : NSObject
@property (strong, nonatomic) NSString *bioguide;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *party;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *stateName;
@property (strong, nonatomic) NSString *termEnd;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *entityID;
@property (strong, nonatomic) NSMutableArray *topContributors;
@property (strong, nonatomic) NSMutableArray *topIndustries;
- (id)initWithData:(NSMutableArray*)data;

@end
