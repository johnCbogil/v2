//
//  LocationService.h
//  Voices
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationService : NSObject <CLLocationManagerDelegate>

+(LocationService *) sharedInstance;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocation *requestedLocation;
@property (strong, nonatomic) NSMutableArray *observers;
@property (nonatomic) BOOL isHomeAddressVC;
- (void)startUpdatingLocation;
- (void)getCoordinatesFromSearchText:(NSString*)searchText withCompletion:(void(^)(CLLocation *results))successBlock
                             onError:(void(^)(NSError *error))errorBlock;

@end
