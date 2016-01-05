//
//  OnboardingPageViewController.m
//  v3
//
//  Created by John Bogil on 1/1/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "OnboardingPageViewController.h"

@interface OnboardingPageViewController ()
@property (nonatomic, strong) NSArray *listOfViewControllers;
@end

@implementation OnboardingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataSource = self;
    self.delegate = self;
    self.firstVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OnboardingViewController"];
    self.secondVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Onboarding2ViewController"];
    self.listOfViewControllers = [NSArray arrayWithObjects:self.firstVC,self.secondVC, nil];
    [self setViewControllers:@[self.firstVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){}];
}

// THESE NEXT TWO METHODS NEED TO RETURN VCs DYNAMICALLY
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (self.viewControllers[0] == self.secondVC){
        return self.firstVC;
    }
    else if (self.viewControllers[0] == self.firstVC){
        return self.secondVC;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if (self.viewControllers[0] == self.firstVC){
        return self.secondVC;
    }
    else if (self.viewControllers[0] == self.secondVC){
        return self.firstVC;
    }
    return nil;
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
