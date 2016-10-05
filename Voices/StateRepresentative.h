//
//  StateRepresentative.h
//  Voices
//
//  Created by John Bogil on 7/24/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Representative.h"

@interface StateRepresentative : Representative

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *chamber;
@property (strong, nonatomic) NSString *upperChamber;
@property (strong, nonatomic) NSString *lowerChamber;

- (id)initWithData:(NSDictionary*)data;
- (id)initGovWithData:(NSDictionary*)data;

@end
