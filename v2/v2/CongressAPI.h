//
//  CongressAPI.h
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface CongressAPI : NSObject
- (void)determineCongressmen:(CLLocation*)currentLocation;

@end
