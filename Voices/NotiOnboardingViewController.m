//
//  NotiOnboardingViewController.m
//  Voices
//
//  Created by John Bogil on 7/14/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NotiOnboardingViewController.h"
#import "LocationOnboardingViewController.h"
#import "VoicesConstants.h"
#import "UIColor+voicesColor.h"
#import "UIFont+voicesFont.h"

#import "AppDelegate.h"

@import FirebaseMessaging;

@interface NotiOnboardingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *turnOnNotiLabel;
@property (weak, nonatomic) IBOutlet UIImageView *notiOnboardingImageView;
@property (weak, nonatomic) IBOutlet UIView *singleLineView;
@property (weak, nonatomic) IBOutlet UIButton *turnOnNotificationsButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation NotiOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.nextButton.enabled = NO;
    
    [self setFont];
}

- (void)setFont {
    
    self.turnOnNotificationsButton.titleLabel.font = [UIFont voicesFontWithSize:21];
    self.turnOnNotificationsButton.backgroundColor = [UIColor voicesOrange];
    self.turnOnNotificationsButton.layer.cornerRadius = kButtonCornerRadius;
    
    self.nextButton.titleLabel.font = [UIFont voicesFontWithSize:13];
    [self.nextButton setTitleColor:[UIColor voicesGray] forState:UIControlStateNormal];
    self.nextButton.alpha = 0.5;
    [self.nextButton setTitle:@"I will later" forState:UIControlStateNormal];
}

- (IBAction)turnOnNotiButtonDidPress:(id)sender {
    
    if (![self.turnOnNotificationsButton.titleLabel.text isEqualToString:@"Next"]) {
        UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];

    }
    else {
        [self pushNextVC];
    }
    
    
//    self.nextButton.enabled = YES;
//    [self.nextButton setTitleColor:[UIColor voicesOrange] forState:UIControlStateNormal];
//    self.nextButton.alpha = 1.0;
    
    [self.turnOnNotificationsButton setTitle:@"Next" forState:UIControlStateNormal];
    self.nextButton.alpha = 0;
}

- (IBAction)nextButtonDidPress:(id)sender {
    
    [self pushNextVC];
}

- (void)pushNextVC {
    
    UIStoryboard *onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle: nil];
    LocationOnboardingViewController *locationOnboardingViewController = (LocationOnboardingViewController *)[onboardingStoryboard instantiateViewControllerWithIdentifier: @"LocationOnboardingViewController"];
    [self.navigationController pushViewController:locationOnboardingViewController animated:YES];

}

@end
