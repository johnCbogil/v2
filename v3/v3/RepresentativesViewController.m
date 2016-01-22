//
//  RepresentativesViewController.m
//  Voices
//
//  Created by Bogil, John on 1/22/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepresentativesViewController.h"

@interface RepresentativesViewController ()
@property (weak, nonatomic) IBOutlet UILabel *screenNumberLabel;

@end

@implementation RepresentativesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.screenNumberLabel.text = [NSString stringWithFormat:@"%lu", self.index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
