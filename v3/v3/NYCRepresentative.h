//
//  NYCRepresentative.h
//  Voices
//
//  Created by John Bogil on 1/23/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NYCRepresentative : NSObject

- (id)initWithData:(NSArray*)data;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *photoURL;
@property (strong, nonatomic) NSString *party;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSDictionary *address;

@end
