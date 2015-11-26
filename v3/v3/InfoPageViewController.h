//
//  InfoPageViewController.h
//  v2
//
//  Created by John Bogil on 10/12/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface InfoPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
+(InfoPageViewController *) sharedInstance;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (nonatomic) BOOL startFromScript;
@end
