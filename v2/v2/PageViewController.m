//
//  MyPageViewController.m
//  v2
//
//  Created by David Weissler on 8/4/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UIViewController *firstVC;
@property (nonatomic, strong) UIViewController *secondVC;
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataSource = self;
    self.delegate = self;
    self.firstVC = [self.storyboard instantiateViewControllerWithIdentifier:@"congresspersonViewController"];
    self.secondVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stateLegislatorViewController"];
    [self setViewControllers:@[self.firstVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // PAGECONTROL IS CREATED HERE BC PARENT NAVIGATIONCONTROLLER ISNT CREATED IN VDL
    self.parentViewController.navigationController.delegate = self;
    CGSize navBarSize = self.navigationController.navigationBar.bounds.size;
    CGPoint origin = CGPointMake( navBarSize.width/2, navBarSize.height/2 );
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(origin.x, origin.y+70, 0, 0)];
    [self.pageControl setNumberOfPages:2];
    self.pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [self.parentViewController.navigationController.navigationBar addSubview:self.pageControl];
    self.parentViewController.navigationItem.title = self.firstVC.title;
    [self.parentViewController.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Avenir" size:18],
      NSFontAttributeName, nil]];
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
        //self.pageControl.currentPage = 0;
        return self.secondVC;
    }
    else if (self.viewControllers[0] == self.secondVC){
       // self.pageControl.currentPage = 1;
        return self.firstVC;
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if(finished)
    {
        self.titleOfIncomingViewController = [[pageViewController.viewControllers firstObject] title];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLabel"
                                                            object:nil];


        self.parentViewController.navigationItem.title =  self.titleOfIncomingViewController;
        if ([self.titleOfIncomingViewController isEqualToString:@"Congress"]) {
            
            self.pageControl.currentPage = 0;
        }
        else {
            self.pageControl.currentPage = 1;
        }
    }
}

@end
