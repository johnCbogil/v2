//
//  Onboarding2ViewController.m
//  Voices
//
//  Created by John Bogil on 1/1/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "Onboarding2ViewController.h"
#import "HomeViewController.h"
#import "UIFont+voicesFont.h"

@interface Onboarding2ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *deferLocationUseButton;
@property (weak, nonatomic) IBOutlet UIButton *permitLocationUseButton;
@property (weak, nonatomic) IBOutlet UILabel *turnOnLocationLabel;

@end

@implementation Onboarding2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.permitLocationUseButton.layer.cornerRadius = 5;
    self.turnOnLocationLabel.font = [UIFont voicesFontWithSize:20];
    self.permitLocationUseButton.titleLabel.font = [UIFont voicesFontWithSize:18];
    self.deferLocationUseButton.titleLabel.font = [UIFont voicesFontWithSize:11];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)permitLocationUseButtonDidPress:(id)sender {
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isOnboardingCompleted"];
    [[LocationService sharedInstance] startUpdatingLocation];
    [LocationService sharedInstance].locationManager.delegate = self;

}
- (IBAction)deferLocationUseButtonDidPress:(id)sender {
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isOnboardingCompleted"];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    HomeViewController *homeViewController = (HomeViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
    // TODO: EVENTUALLY THIS SHOULD DISMISS/POP INSTEAD OF PRESENT OVER
    [self presentViewController:homeViewController animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"location authorization denied");
    }
    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        HomeViewController *homeViewController = (HomeViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
        // TODO: EVENTUALLY THIS SHOULD DISMISS/POP INSTEAD OF PRESENT OVER
        [self presentViewController:homeViewController animated:YES completion:nil];
    }
}

@end
