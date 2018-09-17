
//  LocationManager.m
//  Voices
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "LocationManager.h"
#import "RepsNetworkManager.h"
#import <CoreLocation/CoreLocation.h>

@implementation LocationManager

+ (LocationManager *) sharedInstance {
    
    static LocationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    
    self = [super init];
    if(self != nil) {
    }
    return self;
}

- (void)startUpdatingLocation {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100; // meters
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:AFNetworkingTaskDidSuspendNotification object:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray*)locations {
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    CLLocation *location = [locations lastObject];
    
    // TODO: THIS IS NOT DRY
    self.currentLocation = location;
    self.requestedLocation = location;
    
    __block NSString *address = nil;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(placemarks && placemarks.count > 0) {
            CLPlacemark *placemark= [placemarks objectAtIndex:0];
            address = [NSString stringWithFormat:@"%@ %@, %@ %@ %@", [placemark subThoroughfare],[placemark thoroughfare],[placemark locality], [placemark administrativeArea], [placemark postalCode]];
            NSLog(@"%@",address);
            [[NSUserDefaults standardUserDefaults]setObject:address forKey:kHomeAddress];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"endFetchingStreetAddress" object:nil];
        }
    }];
}

- (void)getCoordinatesFromSearchText:(NSString*)searchText withCompletion:(void(^)(CLLocation *results))successBlock
                             onError:(void(^)(NSError *error))errorBlock {
    NSString *address = searchText;
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {

        CLLocation *location = placemarks[0].location;
        successBlock(location);
    }];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"endRefreshing" object:nil];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"Turn on location services in your Settings app or use the search bar above." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Alright" style:UIAlertActionStyleDefault handler:nil]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    }
    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self.locationManager startUpdatingLocation];
    }
}

@end
