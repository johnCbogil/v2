//
//  OnboardingPageViewController.h
//  v3
//
//  Created by John Bogil on 1/1/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnboardingPageViewController : UIPageViewController  <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) UIViewController *firstVC;
@property (nonatomic, strong) UIViewController *secondVC;
@end
