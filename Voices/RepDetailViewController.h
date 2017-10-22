//
//  RepDetailViewController.h
//  Voices
//
//  Created by Ben Rosenfeld on 8/25/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FederalRepresentative.h"
#import "StateRepresentative.h"
#import "LocalRepresentative.h"
#import "UIImageView+AFNetworking.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface RepDetailViewController : UIViewController  


@property (strong, nonatomic) Representative *representative;


@end
