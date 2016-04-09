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
   
    RepresentativesViewController *repVC = (RepresentativesViewController *)viewController;
    
     if (repVC.index == 1) {
        for (RepresentativesViewController *vc in self.listOfViewControllers) {
            if (vc.index == 0) {
                return vc;
            }
        }
    }
    else if (repVC.index == 2) {
        for (RepresentativesViewController *vc in self.listOfViewControllers) {
            if (vc.index == 1) {
                return vc;
            }
        }
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    RepresentativesViewController *repVC = (RepresentativesViewController *)viewController;

    if (repVC.index == 0) {
        for (RepresentativesViewController *vc in self.listOfViewControllers) {
            if (vc.index == 1) {
                return vc;
            }
        }
    }
    else if (repVC.index == 1) {
        for (RepresentativesViewController *vc in self.listOfViewControllers) {
            if (vc.index == 2) {
                return vc;
            }
        }
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if(finished) {
        NSString *titleOfIncomingViewController = [[pageViewController.viewControllers firstObject] title];
        NSDictionary* userInfo = @{@"currentPage": titleOfIncomingViewController};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changePage" object:userInfo];
    }
}

- (RepresentativesViewController *)viewControllerAtIndex:(NSUInteger)index {
    RepresentativesViewController *representativesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RepresentativesViewController"];
    representativesViewController.index = index;
    return representativesViewController;
}
@end