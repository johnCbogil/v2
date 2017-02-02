//
//  ThankYouViewController.m
//  Voices
//
//  Created by Daniel Nomura on 1/31/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ThankYouViewController.h"
#import <STPopup.h>

@interface ThankYouViewController ()

@end

@implementation ThankYouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Thank You!";
    self.contentSizeInPopup = CGSizeMake(300, 315);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"thankYouViewControllerDismissed" object:nil];
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
