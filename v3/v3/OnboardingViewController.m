//
//  OnboardingViewController.m
//  Voices
//
//  Created by John Bogil on 1/1/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "OnboardingViewController.h"
#import "UIFont+voicesFont.h"
#import "VoicesConstants.h"

@interface OnboardingViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *voicesIcon;
@property (weak, nonatomic) IBOutlet UILabel *firstCivicToolLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation OnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.startButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.startButton.layer.cornerRadius = kButtonCornerRadius;
    self.firstCivicToolLabel.font = [UIFont voicesFontWithSize:23.0];
    self.startButton.titleLabel.font = [UIFont voicesFontWithSize:25.0];
}

@end