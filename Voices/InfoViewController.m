//
//  InfoViewController.m
//  Voices
//
//  Created by John Bogil on 10/11/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "InfoViewController.h"
#import "UIColor+voicesColor.h"
#import <STPopup/STPopup.h>
#import "VoicesConstants.h"

@interface InfoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeWindowButton;

@end

@implementation InfoViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Here's what to say";
        self.contentSizeInPopup = CGSizeMake(300, 315);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Here's what to say";
    self.contentSizeInPopup = CGSizeMake(300, 315);
    self.closeWindowButton.layer.cornerRadius = kButtonCornerRadius;
    self.closeWindowButton.backgroundColor = [UIColor voicesOrange];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (IBAction)closeWindowButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end