//
//  ThankYouViewController.m
//  Voices
//
//  Created by Daniel Nomura on 1/27/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ThankYouViewController.h"

@interface ThankYouViewController ()
@property (weak, nonatomic) IBOutlet UITextView *thankYouTextView;
@property (weak, nonatomic) IBOutlet UIButton *closeWindowButton;

@end

@implementation ThankYouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Thank you for calling!";
    
}

- (IBAction)closeWindowButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
