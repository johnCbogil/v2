//
//  RootViewController.h
//  Voices
//
//  Created by John Bogil on 8/7/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UISearchBarDelegate>

- (void)updateTabForIndex:(NSIndexPath *)indexPath;

@end
