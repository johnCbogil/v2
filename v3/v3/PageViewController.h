//
//  PageViewController.h
//  v3
//
//  Created by David Weissler on 8/4/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

// RENAME THIS CLASS
@interface PageViewController : UIPageViewController
@property (strong, nonatomic) NSString *titleOfIncomingViewController;
@property (assign, nonatomic) NSInteger index;
@end
