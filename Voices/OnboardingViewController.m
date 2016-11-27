//
//  OnboardingViewController.m
//  Voices
//
//  Created by John Bogil on 1/1/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "OnboardingViewController.h"
#import "TabBarViewController.h"

@interface OnboardingViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *voicesIcon;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation OnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setFont];
}

- (void)setFont {
    
    self.startButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.startButton.layer.cornerRadius = kButtonCornerRadius;
    self.startButton.titleLabel.font = [UIFont voicesFontWithSize:25.0];
    self.startButton.backgroundColor = [UIColor voicesOrange];
    self.startButton.titleLabel.minimumScaleFactor = 0.75;

    self.introLabel.font = [UIFont voicesFontWithSize:25.0];
    self.introLabel.text = @"Voices helps you take action to support the causes you care about.";
}
- (IBAction)getStartedButtonDidPress:(id)sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    TabBarViewController *tabVC = (TabBarViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"TabBarViewController"];
    [self.navigationController pushViewController:tabVC animated:YES];

}

@end
