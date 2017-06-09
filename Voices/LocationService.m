
//  LocationService.m
//  Voices
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "LocationService.h"
#import "RepsNetworkManager.h"

@implementation LocationService

+ (LocationService *) sharedInstance {
    
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
            if (self.isHomeAddressVC) {
                [[NSUserDefaults standardUserDefaults]setObject:address forKey:kHomeAddress];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadActionDetailTableView" object:nil];
            }
        }
    }];
}

- (void)getCoordinatesFromSearchText:(NSString*)searchText withCompletion:(void(^)(CLLocation *results))successBlock
                             onError:(void(^)(NSError *error))errorBlock {
    [[RepsNetworkManager sharedInstance]getStreetAddressFromSearchText:searchText withCompletion:^(NSArray *results) {
        if ([[results valueForKey:@"status"]isEqualToString:@"ZERO_RESULTS"]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"We couldn't find your location. Try being more specific." preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
        }
        else {
            CLLocationDegrees latitude = [[[[[results valueForKey:@"results"]valueForKey:@"geometry"]valueForKey:@"location"]valueForKey:@"lat"][0]doubleValue];
            CLLocationDegrees longitude = [[[[[results valueForKey:@"results"]valueForKey:@"geometry"]valueForKey:@"location"]valueForKey:@"lng"][0]doubleValue];
            CLLocation *location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
            self.requestedLocation = location;
            successBlock(location);
        }
    } onError:^(NSError *error) {
        
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
