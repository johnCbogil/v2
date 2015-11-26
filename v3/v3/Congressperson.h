//
//  Congressperson.h
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// these may not need to be exposed in the public interface
@interface Congressperson : NSObject
@property (strong, nonatomic) NSString *bioguide;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *party;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *stateName;
@property (strong, nonatomic) NSString *termEnd;
@property (strong, nonatomic) NSString *nextElection;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *shortTitle;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *twitter;
@property (strong, nonatomic) NSString *influenceExplorerID;
@property (strong, nonatomic) NSString *crpID;
@property (strong, nonatomic) NSData *photo;
@property (strong, nonatomic) NSArray *topContributors;
@property (strong, nonatomic) NSArray *topIndustries;
- (id)initWithData:(NSDictionary *)data;

@end
