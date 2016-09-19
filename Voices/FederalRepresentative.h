//
//  FederalRepresentative.h
//  Voices
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Representative.h"

@interface FederalRepresentative : Representative

@property (strong, nonatomic) NSString *bioguide;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *termEnd;
@property (strong, nonatomic) NSString *shortTitle;
@property (strong, nonatomic) NSString *influenceExplorerID;
@property (strong, nonatomic) NSString *crpID;
@property (strong, nonatomic) NSArray *topContributors;
@property (strong, nonatomic) NSArray *topIndustries;
- (id)initWithData:(NSDictionary *)data;

@end
