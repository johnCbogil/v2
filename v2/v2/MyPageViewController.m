//
//  MyPageViewController.m
//  v2
//
//  Created by David Weissler on 8/4/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "MyPageViewController.h"

@interface MyPageViewController ()<UIPageViewControllerDataSource>
@property (nonatomic, strong) UIViewController *firstVC;
@property (nonatomic, strong) UIViewController *secondVC;
@end

@implementation MyPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataSource = self;
    self.firstVC = [self.storyboard instantiateViewControllerWithIdentifier:@"congresspersonViewController"];
    self.secondVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stateLegislatorViewController"];
    [self setViewControllers:@[self.firstVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {}];
}

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

//- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
//{
//    if(finished)
//    {
//        NSString *titleOfIncomingViewController = [[pageViewController.viewControllers firstObject] title];
//        pageViewController.navigationItem.title = titleOfIncomingViewController;
//    }
//}
@end
