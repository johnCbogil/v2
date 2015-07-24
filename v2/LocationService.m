//
//  LocationService.m
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "LocationService.h"

@implementation LocationService

+(LocationService *) sharedInstance
{
    static LocationService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 100; // meters
        self.locationManager.delegate = self;
    }
    return self;
}

- (void)startUpdatingLocation
{
    NSLog(@"Starting location updates");
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location service failed with error %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray*)locations
{
    CLLocation *location = [locations lastObject];
    NSLog(@"Latitude %+.6f, Longitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude);
    self.currentLocation = location;
    self.locationManager = nil;
    
}


@end
