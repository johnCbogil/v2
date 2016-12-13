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
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Here's what to say";
    self.contentSizeInPopup = CGSizeMake(300, 315);
    self.closeWindowButton.layer.cornerRadius = kButtonCornerRadius;
    self.closeWindowButton.backgroundColor = [UIColor voicesOrange];
    
    self.scriptTextView.editable = NO;
    
    if ([ScriptManager sharedInstance].lastAction.script.length > 0) {
        self.scriptTextView.text = [ScriptManager sharedInstance].lastAction.script;
    }
    else {
        self.scriptTextView.text = kGenericScript;
    }
    [self.scriptTextView sizeToFit];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.scriptTextView.text];
    NSRange yourNameRange = [self.scriptTextView.text rangeOfString:@"your name"];
    NSRange positionRange = [self.scriptTextView.text rangeOfString:@"support/oppose"];
    NSRange issueRange = [self.scriptTextView.text rangeOfString:@"an issue that you care about"];

    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor voicesOrange] range:yourNameRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor voicesOrange] range:positionRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor voicesOrange] range:issueRange];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 35.0f;
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];


    [attributedString addAttribute:NSFontAttributeName value:[UIFont voicesFontWithSize:21] range:NSMakeRange(0, attributedString.length)];

    self.scriptTextView.attributedText = attributedString;
    
    
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (IBAction)closeWindowButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
