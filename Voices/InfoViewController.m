//
//  InfoViewController.m
//  Voices
//
//  Created by John Bogil on 10/11/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "InfoViewController.h"
#import <STPopup/STPopup.h>
#import "ScriptManager.h"

@interface InfoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeWindowButton;
@property (weak, nonatomic) IBOutlet UILabel *scriptLabel;
@property (weak, nonatomic) IBOutlet UITextView *scriptTextView;

@end

@implementation InfoViewController

- (instancetype)init {
    if (self = [super init]) {
        self.contentSizeInPopup = CGSizeMake(300, 315);
        
        // TODO: Set font sizes
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Here's what to say";
    self.contentSizeInPopup = CGSizeMake(300, 315);
    self.closeWindowButton.layer.cornerRadius = kButtonCornerRadius;
    self.closeWindowButton.backgroundColor = [UIColor voicesOrange];
    if ([ScriptManager sharedInstance].lastAction.script.length > 0) {
        self.scriptTextView.text = [ScriptManager sharedInstance].lastAction.script;
    }
    else {
        self.scriptTextView.text = kGenericScript;
    }
    self.scriptTextView.font = [UIFont voicesFontWithSize:21];
    [self.scriptTextView sizeToFit];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (IBAction)closeWindowButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
