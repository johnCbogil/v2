//
//  PageViewController.m
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController (){
    

NSArray *viewControllers;

UIViewController *firstVC;
UIViewController *secondVC;
}
@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create page view controller
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    firstVC = [self.storyboard instantiateViewControllerWithIdentifier:@"congresspersonViewController"];
    secondVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stateLegislatorViewController"];
    
    viewControllers = @[firstVC];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if (self.pageViewController.viewControllers[0] == secondVC)
    {
        return firstVC;
    }
    else if (self.pageViewController.viewControllers[0] == firstVC){
        
        return secondVC;
    }
    
    return nil;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if (self.pageViewController.viewControllers[0] == firstVC){
        return secondVC;
    }
    else if (self.pageViewController.viewControllers[0] == secondVC){
        return firstVC;
    }

    
    return nil;
    
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
