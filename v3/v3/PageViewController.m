//
//  MyPageViewController.m
//  v3
//
//  Created by David Weissler on 8/4/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "PageViewController.h"
#import "RepresentativesViewController.h"

@interface PageViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UIViewController *firstVC;
@property (nonatomic, strong) UIViewController *secondVC;
@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    self.firstVC = [self.storyboard instantiateViewControllerWithIdentifier:@"congresspersonViewController"];
    self.secondVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stateLegislatorViewController"];
    
    RepresentativesViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];

    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){}];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(RepresentativesViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(RepresentativesViewController *)viewController index];
    
    index++;
    
    if (index == 5) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

//- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
//    if(finished) {
//        self.titleOfIncomingViewController = [[pageViewController.viewControllers firstObject] title];
//        NSDictionary* userInfo = @{@"currentPage": self.titleOfIncomingViewController};
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"changePage" object:userInfo];
//    }
//}

- (RepresentativesViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    RepresentativesViewController *childViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RepresentativesViewController"];
    childViewController.index = index;
    
    return childViewController;
    
}
@end