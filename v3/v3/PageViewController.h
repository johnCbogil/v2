//
//  PageViewController.h
//  v3
//
//  Created by David Weissler on 8/4/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageViewController : UIPageViewController
@property (strong, nonatomic) NSString *titleOfIncomingViewController;
// NOT SURE IF I NEED THIS
@property (assign, nonatomic) NSInteger index;
@end
