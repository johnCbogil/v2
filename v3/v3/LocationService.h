//
//  LocationService.h
//  Voices
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// NOT SURE IF I NEED THIS
@protocol LocationObserver <NSObject>
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray*)locations;
@end

@interface LocationService : NSObject <CLLocationManagerDelegate>

+(LocationService *) sharedInstance;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSMutableArray *observers;
- (void)startUpdatingLocation;
- (void)getCoordinatesFromSearchText:(NSString*)searchText withCompletion:(void(^)(CLLocation *results))successBlock
                             onError:(void(^)(NSError *error))errorBlock;

@end