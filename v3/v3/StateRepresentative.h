//
//  StateLegislator.h
//  Voices
//
//  Created by John Bogil on 7/24/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StateRepresentative : NSObject
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *party;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSURL *photoURL;
@property (strong, nonatomic) NSData *photo;
@property (strong, nonatomic) NSString *stateCode;
@property (strong, nonatomic) NSString *districtNumber;
@property (strong, nonatomic) NSString *chamber;
@property (strong, nonatomic) NSString *upperChamber;
@property (strong, nonatomic) NSString *lowerChamber;
- (id)initWithData:(NSDictionary*)data;
@end