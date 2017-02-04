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

@property (strong, nonatomic) NSString *termEnd;
- (id)initWithData:(NSDictionary *)data;

@end
