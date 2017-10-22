//
//  LocalRepresentative.h
//  Voices
//
//  Created by John Bogil on 1/23/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Representative.h"

@interface LocalRepresentative : Representative

- (id)initWithData:(NSDictionary*)data;

@property (strong, nonatomic) NSString *borough;

@end
