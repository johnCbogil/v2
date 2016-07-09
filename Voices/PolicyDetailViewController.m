//
//  PolicyDetailViewController.m
//  Voices
//
//  Created by Bogil, John on 7/7/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "PolicyDetailViewController.h"

@interface PolicyDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *policySubjectLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactRepsButton;
@property (weak, nonatomic) IBOutlet UITextView *policyPositionTextView;

@end

@implementation PolicyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setFont];
    self.title = @"TAKE ACTION";
    
    self.policySubjectLabel.text = self.policyPosition.key;
    self.policyPositionTextView.text = self.policyPosition.policyPosition; // NOT GOOD NAMING
    
}

- (void)setFont {
    
}

- (IBAction)contactRepsButtonDidPress:(id)sender {
    self.tabBarController.selectedIndex = 0;
}

@end
