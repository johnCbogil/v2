//
//  NotiOnboardingViewController.m
//  Voices
//
//  Created by John Bogil on 7/14/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NotiOnboardingViewController.h"
#import "VoicesConstants.h"
#import "UIColor+voicesColor.h"
#import "UIFont+voicesFont.h"

@interface NotiOnboardingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *turnOnNotiLabel;
@property (weak, nonatomic) IBOutlet UIImageView *notiOnboardingImageView;
@property (weak, nonatomic) IBOutlet UIView *singleLineView;
@property (weak, nonatomic) IBOutlet UIButton *turnOnNotificationsButton;
@property (weak, nonatomic) IBOutlet UIButton *deferNotiButton;

@end

@implementation NotiOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)deferNotiButtonDidPress:(id)sender {
}

- (IBAction)turnOnNotiButtonDidPress:(id)sender {
}

@end
