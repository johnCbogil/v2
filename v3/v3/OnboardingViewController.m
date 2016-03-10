//
//  OnboardingViewController.m
//  v3
//
//  Created by John Bogil on 1/1/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "OnboardingViewController.h"

@interface OnboardingViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *voicesIcon;
@property (weak, nonatomic) IBOutlet UILabel *firstCivicToolLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation OnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.startButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.startButton.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
