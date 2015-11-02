//
//  InfoPageViewController.m
//  v2
//
//  Created by John Bogil on 10/12/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "InfoPageViewController.h"
#import <STPopup/STPopup.h>
#import "UIFont+voicesFont.h"
@interface InfoPageViewController ()
@property (nonatomic, strong) UIViewController *firstVC;
@property (nonatomic, strong) UIViewController *secondVC;
@property (nonatomic, strong) UIViewController *thirdVC;
@property (nonatomic, strong) NSArray *listOfViewControllers;
@end

@implementation InfoPageViewController
+ (InfoPageViewController *)sharedInstance {
    static InfoPageViewController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"About";
    
    CGRect frame = CGRectMake(0, 0, 100, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont voicesFontWithSize:22];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = self.navigationItem.title;
    self.navigationItem.titleView = label;
    
    self.dataSource = self;
    self.delegate = self;
    self.firstVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoViewControllerOne"];
    self.secondVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoViewControllerTwo"];
    self.thirdVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoViewControllerThree"];
    // THIS FEELS LIKE A HACK
    if ([InfoPageViewController sharedInstance].startFromScript) {
        [self setViewControllers:@[self.secondVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){}];
    }
    else {
        [self setViewControllers:@[self.firstVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){}];
    }
    self.contentSizeInPopup = CGSizeMake(300, 400);
    self.listOfViewControllers = @[self.firstVC, self.secondVC, self.thirdVC];
    
    self.pageControl = [UIPageControl appearance];
    self.pageControl.pageIndicatorTintColor = [UIColor groupTableViewBackgroundColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.currentPage = 1;
}

- (void)viewDidAppear:(BOOL)animated {
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (self.viewControllers[0] == self.secondVC){
        return self.firstVC;
    }
    else if (self.viewControllers[0] == self.thirdVC){
        return self.secondVC;
    }
    else if (self.viewControllers[0] == self.firstVC){
        return self.thirdVC;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if (self.viewControllers[0] == self.firstVC){
        return self.secondVC;
    }
    else if (self.viewControllers[0] == self.secondVC){
        return self.thirdVC;
    }
    else if (self.viewControllers[0] == self.thirdVC){
        return self.firstVC;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 3;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // THIS FEELS LIKE A HACK
    if ([InfoPageViewController sharedInstance].startFromScript == 1) {
        return 1;
    }
    else {
        return 0;
    }
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