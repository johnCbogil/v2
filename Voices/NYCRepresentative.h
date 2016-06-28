//
//  NYCRepresentative.h
//  Voices
//
//  Created by John Bogil on 1/23/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NYCRepresentative : NSObject

- (id)initWithData:(NSDictionary*)data;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSURL *photoURL;
@property (strong, nonatomic) NSString *party;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *districtAddress;
@property (strong, nonatomic) NSString *legAddress;
@property (strong, nonatomic) NSString *districtNumber;
@property (strong, nonatomic) NSString *borough;
@property (strong, nonatomic) NSData *photo;
@property (strong, nonatomic) NSString *twitter;
@property (strong, nonatomic) NSString *gender;

@end
