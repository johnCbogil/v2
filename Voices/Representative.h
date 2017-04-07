//
//  Representative.h
//  Voices
//
//  Created by Ben Rosenfeld on 9/18/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Representative : NSObject

@property (strong, nonatomic) NSString *bioguide;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSURL *photoURL;
@property (strong, nonatomic) NSString *party;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *districtAddress;
@property (strong, nonatomic) NSString *legAddress;
@property (strong, nonatomic) NSString *districtNumber;
@property (strong, nonatomic) NSData *photo;
@property (strong, nonatomic) NSString *twitter;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *shortTitle;
@property (strong, nonatomic) NSString *nextElection;
@property (strong, nonatomic) NSString *stateName;
@property (strong, nonatomic) NSString *stateCode;
@property (strong, nonatomic) NSString *districtFullName;
@property (strong, nonatomic) NSURL *contactFormURL;

-(void) generateDistrictName;


@end
