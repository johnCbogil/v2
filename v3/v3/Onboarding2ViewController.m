//
//  Onboarding2ViewController.m
//  v3
//
//  Created by John Bogil on 1/1/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "Onboarding2ViewController.h"

@interface Onboarding2ViewController ()
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIButton *deferLocationUseButton;
@property (weak, nonatomic) IBOutlet UIButton *permitLocationUseButton;

@end

@implementation Onboarding2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.permitLocationUseButton.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)permitLocationUseButtonDidPress:(id)sender {
}
- (IBAction)deferLocationUseButtonDidPress:(id)sender {
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
