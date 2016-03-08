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
@property (nonatomic, strong) NSArray *listOfViewControllers;
@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    
    // THESE TITLE VALUES SHOULD BE CONSTANTS
    RepresentativesViewController *initialViewController = [self viewControllerAtIndex:0];
    initialViewController.title = @"Congress";
    RepresentativesViewController *secondViewController = [self viewControllerAtIndex:1];
    secondViewController.title = @"State Legislators";
    RepresentativesViewController *thirdViewController = [self viewControllerAtIndex:2];
    thirdViewController.title = @"NYC Council";
    
    NSArray *viewControllers = @[initialViewController];
    self.listOfViewControllers = @[initialViewController,secondViewController,thirdViewController];
    
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){}];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if ([viewController.title isEqualToString:@"Congress"]) {
        return nil;
    }
    else if ([viewController.title isEqualToString:@"State Legislators"]) {
        for (RepresentativesViewController *vc in self.listOfViewControllers) {
            if ([vc.title isEqualToString:@"Congress"]) {
                return vc;
            }
        }
    }
    else if ([viewController.title isEqualToString:@"NYC Council"]) {
        for (RepresentativesViewController *vc in self.listOfViewControllers) {
            if ([vc.title isEqualToString:@"State Legislators"]) {
                return vc;
            }
        }
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if ([viewController.title isEqualToString:@"Congress"]) {
        for (RepresentativesViewController *vc in self.listOfViewControllers) {
            if ([vc.title isEqualToString:@"State Legislators"]) {
                return vc;
            }
        }
    }
    else if ([viewController.title isEqualToString:@"State Legislators"]) {
        for (RepresentativesViewController *vc in self.listOfViewControllers) {
            if ([vc.title isEqualToString:@"NYC Council"]) {
                return vc;
            }
        }
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if(finished) {
        self.titleOfIncomingViewController = [[pageViewController.viewControllers firstObject] title];
        NSDictionary* userInfo = @{@"currentPage": self.titleOfIncomingViewController};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changePage" object:userInfo];
    }
}

- (RepresentativesViewController *)viewControllerAtIndex:(NSUInteger)index {
    RepresentativesViewController *representativesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RepresentativesViewController"];
    representativesViewController.index = index;
    return representativesViewController;
}
@end