//
//  PolicyDetailViewController.m
//  Voices
//
//  Created by Bogil, John on 7/7/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "PolicyDetailViewController.h"
#import "WebViewController.h"

@interface PolicyDetailViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *contactRepsButton;
@property (weak, nonatomic) IBOutlet UITextView *policyPositionTextView;

@end

@implementation PolicyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setFont];
    self.title = self.policyPosition.key;
    self.policyPositionTextView.text = self.policyPosition.policyPosition; // TODO: NOT GOOD NAMING
    self.policyPositionTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.policyPositionTextView.delegate = self;
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    self.contactRepsButton.layer.cornerRadius = kButtonCornerRadius;
}

- (void)setFont {
    self.policyPositionTextView.font = [UIFont voicesFontWithSize:19];
    self.contactRepsButton.titleLabel.font = [UIFont voicesFontWithSize:21];
}

- (void)viewDidLayoutSubviews {
    [self.policyPositionTextView setContentOffset:CGPointZero animated:NO]; // This is here to ensure the scrollview starts from the top
}

- (IBAction)contactRepsButtonDidPress:(id)sender {
    self.tabBarController.selectedIndex = 0;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    WebViewController *webViewController = (WebViewController *)[repsSB instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = URL;
    webViewController.title = @"TAKE ACTION";
    [self.navigationController pushViewController:webViewController animated:YES];
    return NO;
}

@end
