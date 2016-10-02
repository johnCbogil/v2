//
//  MyPageViewController.m
//  v3
//
//  Created by David Weissler on 8/4/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "PageViewController.h"
#import "RepsViewController.h"

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
    
    RepsViewController *initialViewController = [self viewControllerAtIndex:0];
    initialViewController.title = @"Federal";
    RepsViewController *secondViewController = [self viewControllerAtIndex:1];
    secondViewController.title = @"State";
    RepsViewController *thirdViewController = [self viewControllerAtIndex:2];
    thirdViewController.title = @"Local";
    
    
    NSArray *viewControllers = @[initialViewController];
    self.listOfViewControllers = @[initialViewController,secondViewController,thirdViewController];
    
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePage:) name:@"jumpPage" object:nil];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    RepsViewController *repVC = (RepsViewController *)viewController;
    
    if (repVC.index == 1) {
        for (RepsViewController *vc in self.listOfViewControllers) {
            if (vc.index == 0) {
                return vc;
            }
        }
    }
    else if (repVC.index == 2) {
        for (RepsViewController *vc in self.listOfViewControllers) {
            if (vc.index == 1) {
                return vc;
            }
        }
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    RepsViewController *repVC = (RepsViewController *)viewController;
    
    if (repVC.index == 0) {
        for (RepsViewController *vc in self.listOfViewControllers) {
            if (vc.index == 1) {
                return vc;
            }
        }
    }
    else if (repVC.index == 1) {
        for (RepsViewController *vc in self.listOfViewControllers) {
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

- (RepsViewController *)viewControllerAtIndex:(NSUInteger)index {
    RepsViewController *repsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RepsViewController"];
    repsViewController.index = index;
    return repsViewController;
}

// TODO: DETERMINE THE CURRENT PAGE SO THAT I CAN SET THE ANIMATION DIRECTION
- (void)changePage:(NSNotification *)notification {
    
    long int pageNumber = [notification.object integerValue];
    RepsViewController *vc = self.listOfViewControllers[pageNumber];

    
    [self setViewControllers:@[vc]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}
@end
