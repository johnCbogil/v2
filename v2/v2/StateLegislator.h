//
//  StateLegislator.h
//  v2
//
//  Created by John Bogil on 7/24/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StateLegislator : NSObject
// these may not need to be exposed in the public interface
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSURL *photoURL;
- (id)initWithData:(NSMutableArray*)data;

@end
