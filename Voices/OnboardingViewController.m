//
//  OnboardingViewController.m
//  Voices
//
//  Created by John Bogil on 1/1/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "OnboardingViewController.h"
#import "NotiOnboardingViewController.h"
#import "AppDelegate.h"
#import "TabBarViewController.h"
@interface OnboardingViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *voicesIcon;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation OnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    [self setFont];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)setFont {
    
    self.startButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.startButton.layer.cornerRadius = kButtonCornerRadius;
    self.startButton.titleLabel.font = [UIFont voicesFontWithSize:25.0];
    self.startButton.backgroundColor = [UIColor voicesOrange];
    self.startButton.titleLabel.minimumScaleFactor = 0.75;

    self.introLabel.font = [UIFont voicesFontWithSize:30];
    self.introLabel.text = @"Support the groups and causes you care about.";
}

- (IBAction)getStartedButtonDidPress:(id)sender {
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    backButtonItem.tintColor = [UIColor voicesOrange];
    [self.navigationItem setBackBarButtonItem:backButtonItem];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    TabBarViewController *tabVC = (TabBarViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"TabBarViewController"];
    [self.navigationController pushViewController:tabVC animated:YES]; 

}

@end
