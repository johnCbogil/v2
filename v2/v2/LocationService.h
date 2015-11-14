//
//  LocationService.h
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ToggleZeroStateDelegate <NSObject>
- (void)toggleZeroState:(BOOL)state;
@end

@interface LocationService : NSObject <CLLocationManagerDelegate>
+(LocationService *) sharedInstance;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) id <ToggleZeroStateDelegate> toggleZeroStateDelegate;
- (void)startUpdatingLocation;
- (void)getCoordinatesFromSearchText:(NSString*)searchText withCompletion:(void(^)(CLLocation *results))successBlock
                             onError:(void(^)(NSError *error))errorBlock;
@end